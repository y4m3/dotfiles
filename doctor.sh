#!/bin/bash
# Read-only environment health check for the Linux side, the counterpart of
# doctor.ps1. Changes nothing; always exits 0. Reports "ok:"/"warn:" lines
# and a final warning count, so drift (an "accidentally working" setup)
# shows up before it bites.
#
# The two failures that prompted this script both looked fine from the
# shell: a tool in ~/.local/bin shadowing the Nix-supplied one of the same
# name, and a git identity never filled in because ~/.gitconfig.local is
# created once and then owned by the machine.

# The caller's shell options are not this script's to inherit. Under an
# inherited errexit, the first `value=$(command)` whose command reports
# "not found" would end the run with no report and a non-zero status —
# precisely the machine this script exists to describe. nounset would do
# the same to an array that legitimately came back empty.
set +eu

warnings=0

ok() { echo "ok: $1"; }
warn() {
  echo "warn: $1"
  warnings=$((warnings + 1))
}
finish() {
  echo
  echo "$warnings warning(s)"
  exit 0
}

# Every check below reads the repo, so a failure here is worth a line of
# its own rather than a silent exit.
if ! cd "$(dirname "$0")"; then
  warn "could not enter the script's own directory: $(dirname "$0")"
  finish
fi

# --- Declared Nix packages ---------------------------------------------------

yaml=home/.chezmoidata/packages.yaml
if [ ! -r "$yaml" ]; then
  warn "packages.yaml not found: $yaml"
else
  # Same approach as doctor.ps1: pull the block out by hand rather than take
  # a YAML parser as a dependency. The nix block nests one level (cockpit,
  # inspect, ...), so collect every list item until the next top-level key.
  mapfile -t packages < <(awk '
    /^  nix:/ { inblock = 1; next }
    inblock && /^  [^ ]/ { inblock = 0 }
    inblock && /^[ \t]*-[ \t]/ {
      sub(/^[ \t]*-[ \t]+/, "")
      sub(/[ \t]*#.*/, "")
      sub(/[ \t]+$/, "")
      if ($0 != "") print
    }
  ' "$yaml")

  [ "${#packages[@]}" -gt 0 ] || warn "no nix packages found in $yaml (did its layout change?)"

  for pkg in "${packages[@]}"; do
    # A Nix package installs a binary under a name of its own. These two
    # differ; everything else in the block matches.
    case "$pkg" in
    ripgrep) bin=rg ;;
    neovim) bin=nvim ;;
    *) bin=$pkg ;;
    esac

    if ! resolved=$(command -v "$bin" 2>/dev/null); then
      warn "nix package not on PATH: $pkg (looked for '$bin')"
      continue
    fi

    # The two profiles .bashrc puts on PATH: Home Manager's, and the
    # daemon's default one. Anywhere else under /nix/var/nix/profiles is
    # another user's, and their binary winning a lookup is not "installed".
    # The bug this catches: ~/.local/bin sits ahead of ~/.nix-profile/bin on
    # PATH, so a stale copy there wins and the Nix package that
    # packages.yaml promises is never the one that runs.
    case "$resolved" in
    "$HOME"/.nix-profile/bin/* | /nix/var/nix/profiles/default/bin/*)
      ok "$bin -> $resolved"
      ;;
    *)
      warn "$bin comes from outside the nix profile: $resolved (declared as nix package '$pkg')"
      ;;
    esac
  done
fi

# --- PATH --------------------------------------------------------------------

# An empty entry means the current directory, so a build artefact in
# whatever directory you happen to be in can win a lookup. Check the raw
# string: splitting drops the empty fields that carry this.
case "$PATH" in
:* | *::* | *:) warn "PATH has an empty entry, which puts the current directory on it" ;;
esac

# Under WSL, interop appends the whole Windows PATH to the Linux one. Those
# entries are not this side's to fix, and doctor.ps1 already covers them —
# from the registry, where the durable value lives, rather than from a live
# process, which carries whatever the program that started it happened to
# add. Reporting them here only produces noise nobody can act on.
wsl=no
grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null && wsl=yes

seen=
skipped=0
IFS=: read -r -a path_entries <<<"$PATH"
for entry in "${path_entries[@]}"; do
  [ -n "$entry" ] || continue
  if [ "$wsl" = yes ]; then
    case "$entry" in
    /mnt/*)
      skipped=$((skipped + 1))
      continue
      ;;
    esac
  fi
  # A trailing slash names the same directory, but "/" is all slash: strip it
  # and the empty key left over matches every entry seen so far.
  norm=${entry%/}
  norm=${norm:-/}
  case ":$seen:" in
  *":$norm:"*) warn "duplicate PATH entry: $entry" ;;
  *) seen="$seen:$norm" ;;
  esac
  [ -d "$entry" ] || warn "PATH entry is not a directory: $entry"
done
# Say what was left out, so a clean report is not mistaken for full coverage.
[ "$skipped" -eq 0 ] || ok "skipped $skipped Windows PATH entries added by WSL interop (doctor.ps1 checks that side)"

# --- Files chezmoi creates once and then leaves alone ------------------------

# ~/.gitconfig.local is a create_ file: chezmoi writes the template the
# first time and never touches it again, so an unedited one keeps the
# placeholder identity and every commit carries it.
for field in user.name user.email; do
  value=$(git config --get "$field" 2>/dev/null)
  if [ -z "$value" ]; then
    warn "git $field is not set (write it in ~/.gitconfig.local)"
  else
    ok "git $field = $value"
  fi
done

finish
