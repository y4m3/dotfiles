" encodings
set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set ambiwidth=double

" no backup
set nobackup
set noswapfile
set nowritebackup

" history
set history=10000

" visual
filetype plugin indent on
set cinoptions+=:0
set cmdheight=2
set display=lastline
set laststatus=2
set listchars=tab:^\ ,trail:~
set noerrorbells
set number
set showmatch
set showmatch matchtime=1
set title
syntax on

" search
set incsearch
set ignorecase
set smartcase
set wrapscan
set hlsearch
nmap <silent> <Esc><Esc> :nohlsearch<CR>
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" editor basics
set autoindent
set smartindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set whichwrap=b,s,h,l,<,>,[,],~
set mouse=a
set backspace=indent,eol,start

" keymap
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk
inoremap jj <Esc>

" cilpboard
set clipboard=unnamed,autoselect
set guioptions+=a

" paste
if &term =~ "xterm"
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function XTermPasteBegin(ret)
    set paste
    return a:ret
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif
