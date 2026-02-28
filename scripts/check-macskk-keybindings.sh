#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_PATH="$ROOT_DIR/home/private_Library/private_Containers/private_net.mtgto.inputmethod.macSKK/private_Data/private_Library/private_Preferences/private_net.mtgto.inputmethod.macSKK.plist"

tmp_plist="$(mktemp)"
trap 'rm -f "$tmp_plist"' EXIT

chezmoi execute-template <"$TEMPLATE_PATH" >"$tmp_plist"
plutil -lint "$tmp_plist" >/dev/null

duplicates="$(
  plutil -convert json -o - "$tmp_plist" \
    | jq -r '.keyBindingSets[0].keyBindings[] as $b | $b.action as $a | $b.inputs[]? | [(.key|tostring),(.modifierFlags|tostring),(.optionalModifierFlags|tostring),$a] | @tsv' \
    | sort \
    | awk -F'\t' '
        {
          combo = $1 "\t" $2 "\t" $3
          actions[combo] = (combo in actions ? actions[combo] "," $4 : $4)
          count[combo]++
        }
        END {
          for (combo in count) {
            if (count[combo] > 1) {
              print combo "\t" actions[combo]
            }
          }
        }
      '
)"

if [[ -n "$duplicates" ]]; then
  echo "Duplicate macSKK key bindings detected (key, modifierFlags, optionalModifierFlags, actions):" >&2
  echo "$duplicates" >&2
  exit 1
fi

echo "macSKK key bindings are unique."
