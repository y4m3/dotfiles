" dein basic setting
if &compatible
  set nocompatible               " Be iMproved
endif
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

let g:cache_home = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let g:config_home = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME

" dein {{{
let s:dein_cache_dir = g:cache_home . '/dein'

" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END

if &runtimepath !~# '/dein.vim'
    let s:dein_repo_dir = s:dein_cache_dir . '/repos/github.com/Shougo/dein.vim'

    " Auto Download
    if !isdirectory(s:dein_repo_dir)
        call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
    endif

    " load dein.vim as plugin
    execute 'set runtimepath^=' . s:dein_repo_dir
endif

" dein.vim settings
let g:dein#install_max_processes = 16
let g:dein#install_progress_type = 'title'
let g:dein#install_message_type = 'none'
let g:dein#enable_notification = 1

if dein#load_state(s:dein_cache_dir)
    call dein#begin(s:dein_cache_dir)

    let s:toml_dir = g:config_home . '/nvim'

    call dein#load_toml(s:toml_dir . '/basic.toml', {'lazy': 0})
    call dein#load_toml(s:toml_dir . '/appearance.toml', {'lazy': 0})
    call dein#load_toml(s:toml_dir . '/denite.toml', {'lazy': 0})
    call dein#load_toml(s:toml_dir . '/deoplete.toml', {'lazy': 0})
    call dein#load_toml(s:toml_dir . '/operation.toml', {'lazy': 0})
    call dein#load_toml(s:toml_dir . '/linter.toml', {'lazy': 0})
    call dein#load_toml(s:toml_dir . '/git.toml', {'lazy': 0})

    " lazy load
    call dein#load_toml(s:toml_dir . '/quickrun.toml', {'lazy': 1})
    call dein#load_toml(s:toml_dir . '/language/markdown.toml', {'lazy': 1})
    call dein#load_toml(s:toml_dir . '/language/python.toml', {'lazy': 1})
    call dein#load_toml(s:toml_dir . '/language/toml.toml', {'lazy': 1})

    call dein#end()
    call dein#save_state()
endif

if has('vim_starting') && dein#check_install()
    call dein#install()
endif

"------------------------------------
" Setting
"------------------------------------
" python
let g:loaded_python_provider = 1

" filetype
filetype plugin indent on

" sql
augroup fileTypeIndent
    autocmd!
    autocmd BufNewFile,BufRead *.sql setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

"------------------------------------
" Behavior
"------------------------------------
" memory where edited
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\""

" Backup
set nowritebackup
set nobackup
set noswapfile

" UNDO
if has('persistent_undo')
    set undodir=~/.cache/undo
    set undofile
endif

" encode
set encoding=utf8
scriptencoding utf-8
set fileencoding=utf-8
set termencoding=utf-8

" mouse
set mouse=a

" clipboard
set clipboard+=unnamed
set clipboard=unnamed

" shell
set sh=zsh
command! -nargs=* Ts split | terminal <args>
command! -nargs=* Tv vsplit | terminal <args>

"------------------------------------
" Keybind
"------------------------------------
set wildmenu
let mapleader = ","
let maplocalleader = ","
nnoremap ; :
inoremap <silent> jj <ESC>
set backspace=indent,eol,start
nnoremap <Down> gj
nnoremap <Up>   gk
nnoremap j gj
nnoremap k gk

nnoremap <C-w>c :<C-u>tabnew<CR>
nnoremap <C-w>n gt
nnoremap <C-w>p gT

if has('nvim')
  tnoremap <silent> <ESC> <C-\><C-n>
endif

"------------------------------------
" Appearance
"------------------------------------
syntax on
set wrap
set number
set ruler
set colorcolumn=80
set showmatch
set showcmd
set smarttab
set tabstop=4
set title
set cmdheight=2
set laststatus=2
set expandtab
set tabstop=4
set shiftwidth=4
set smarttab
set showtabline=2
set splitbelow
set splitright

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set list
set listchars=tab:^\ ,trail:~

" highlight spaces
augroup HighlightTrailingSpaces
    autocmd!
    autocmd VimEnter,WinEnter,ColorScheme * highlight TrailingSpaces term=underline guibg=Red ctermbg=Red
    autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
augroup END
"------------------------------------
" Search
"------------------------------------
nmap <silent> <Esc><Esc> :nohlsearch<CR>
set history=10000
set infercase
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
