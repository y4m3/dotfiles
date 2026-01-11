" ~/.vim/autoload/clipboard.vim
" Cross-environment clipboard integration for Vim
" Supports: WSL, SSH (OSC 52), tmux, zellij, local Linux/X11/Wayland

" Environment detection (cached)
let s:env = ''

function! s:detect_env() abort
  if !empty(s:env)
    return s:env
  endif

  " Priority: WSL > X11/Wayland > SSH > OSC52 fallback
  " WSL first: win32yank/clip.exe are most reliable in WSL (even with WSLg)
  " X11/Wayland second: for native Linux or SSH with X11 forwarding
  if !empty($WSL_DISTRO_NAME)
    let s:env = 'wsl'
  elseif !empty($DISPLAY) || !empty($WAYLAND_DISPLAY)
    let s:env = 'x11'
  elseif !empty($SSH_CONNECTION)
    let s:env = 'ssh'
  else
    let s:env = 'osc52'
  endif

  return s:env
endfunction

" Check if inside tmux
function! s:in_tmux() abort
  return !empty($TMUX)
endfunction

" Check if inside zellij
function! s:in_zellij() abort
  return !empty($ZELLIJ)
endfunction

" Encode text to base64
function! s:base64_encode(text) abort
  let l:result = system('base64 | tr -d "\n"', a:text)
  if v:shell_error
    echoerr 'clipboard.vim: base64 encoding failed'
    return ''
  endif
  return l:result
endfunction

" Build OSC 52 sequence
function! s:osc52_sequence(text) abort
  let l:encoded = s:base64_encode(a:text)
  if empty(l:encoded)
    return ''
  endif

  let l:osc = "\x1b]52;c;" . l:encoded . "\x07"

  " Wrap for tmux (but not zellij - it passes OSC 52 natively)
  if s:in_tmux() && !s:in_zellij()
    let l:osc = "\x1bPtmux;\x1b" . l:osc . "\x1b\\"
  endif

  return l:osc
endfunction

" Write OSC 52 sequence to terminal
function! s:write_osc52(text) abort
  let l:seq = s:osc52_sequence(a:text)
  if empty(l:seq)
    return 0
  endif
  call writefile([l:seq], '/dev/tty', 'b')
  return 1
endfunction

" Copy to clipboard based on environment
function! clipboard#copy(text) abort
  let l:env = s:detect_env()

  if l:env ==# 'wsl'
    " WSL: Use win32yank.exe or clip.exe
    if executable('win32yank.exe')
      call system('win32yank.exe -i --crlf', a:text)
      if v:shell_error
        echoerr 'clipboard.vim: win32yank.exe failed'
      endif
    elseif executable('clip.exe')
      call system('clip.exe', a:text)
      if v:shell_error
        echoerr 'clipboard.vim: clip.exe failed'
      endif
    else
      " Fallback to OSC 52
      call s:write_osc52(a:text)
    endif
  elseif l:env ==# 'x11'
    " X11/Wayland: Use xclip, xsel, or wl-copy
    if executable('xclip')
      call system('xclip -in -selection clipboard', a:text)
      if v:shell_error
        echoerr 'clipboard.vim: xclip failed'
      endif
    elseif executable('xsel')
      call system('xsel --clipboard --input', a:text)
      if v:shell_error
        echoerr 'clipboard.vim: xsel failed'
      endif
    elseif executable('wl-copy')
      call system('wl-copy', a:text)
      if v:shell_error
        echoerr 'clipboard.vim: wl-copy failed'
      endif
    else
      " Fallback to OSC 52
      call s:write_osc52(a:text)
    endif
  else
    " SSH or unknown: Use OSC 52
    call s:write_osc52(a:text)
  endif
endfunction

" Paste from clipboard based on environment
function! clipboard#paste() abort
  let l:env = s:detect_env()

  if l:env ==# 'wsl'
    " WSL: Use win32yank.exe or powershell
    if executable('win32yank.exe')
      let l:result = system('win32yank.exe -o --lf')
      if v:shell_error
        echoerr 'clipboard.vim: win32yank.exe paste failed'
        return ''
      endif
      return l:result
    elseif executable('powershell.exe')
      " Use Get-Clipboard -Raw to avoid extra newlines, then strip CRLF
      let l:result = system('powershell.exe -NoProfile -Command "Get-Clipboard -Raw" | tr -d "\r"')
      if v:shell_error
        echoerr 'clipboard.vim: powershell.exe paste failed'
        return ''
      endif
      return l:result
    endif
  elseif l:env ==# 'x11'
    " X11/Wayland: Use xclip, xsel, or wl-paste
    if executable('xclip')
      let l:result = system('xclip -out -selection clipboard')
      if v:shell_error
        return ''  " Silent fail - clipboard may be empty
      endif
      return l:result
    elseif executable('xsel')
      let l:result = system('xsel --clipboard --output')
      if v:shell_error
        return ''
      endif
      return l:result
    elseif executable('wl-paste')
      let l:result = system('wl-paste --no-newline')
      if v:shell_error
        return ''
      endif
      return l:result
    endif
  endif

  " SSH: Cannot read clipboard via OSC 52 (security restriction)
  " Return empty - user should use terminal's paste
  return ''
endfunction

" TextYankPost handler - only sync yank operations
function! clipboard#on_yank() abort
  " Only handle yank (y), not delete (d), change (c), or cut (x)
  if v:event.operator !=# 'y'
    return
  endif

  " Get yanked text
  let l:text = join(v:event.regcontents, "\n")
  if v:event.regtype ==# 'V'
    let l:text .= "\n"
  endif

  call clipboard#copy(l:text)
endfunction

" Setup function called from vimrc
function! clipboard#setup() abort
  " TextYankPost autocmd for yank-only clipboard sync
  augroup ClipboardIntegration
    autocmd!
    autocmd TextYankPost * call clipboard#on_yank()
  augroup END

  " Paste mappings (leader+p/P to paste from system clipboard)
  nnoremap <silent> <leader>p :call <SID>paste_from_clipboard('p')<CR>
  nnoremap <silent> <leader>P :call <SID>paste_from_clipboard('P')<CR>
endfunction

" Internal paste helper
function! s:paste_from_clipboard(cmd) abort
  let l:text = clipboard#paste()
  if empty(l:text)
    " Fallback to normal paste if clipboard is empty or unavailable
    execute 'normal! ' . a:cmd
    return
  endif

  " Put text from clipboard into unnamed register and paste
  let @" = l:text
  execute 'normal! ' . a:cmd
endfunction

" Debug function to show current environment
function! clipboard#info() abort
  echo 'Environment: ' . s:detect_env()
  echo 'In tmux: ' . (s:in_tmux() ? 'yes' : 'no')
  echo 'In zellij: ' . (s:in_zellij() ? 'yes' : 'no')
  echo '$DISPLAY: ' . $DISPLAY
  echo '$WAYLAND_DISPLAY: ' . $WAYLAND_DISPLAY
  echo '$WSL_DISTRO_NAME: ' . $WSL_DISTRO_NAME
  echo '$SSH_CONNECTION: ' . $SSH_CONNECTION
endfunction
