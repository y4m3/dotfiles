# ssh with fzf
## dependency: fzf, rg
function sshh() {
  local host=$(rg -E "^Host " ~/.ssh/config | sed -e 's/Host[ ]*//g' | fzf)
  if [ -n "$host" ]; then
    ssh $host
  fi
}
