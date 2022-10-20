set nocompatible

""" Map leader to space
let mapleader = " "

let &t_SI = "\e[5 q"
let &t_EI = "\e[2 q"
set backspace=indent,eol,start

""" Plugins
call plug#begin()

Plug 'rafi/awesome-vim-colorschemes'
Plug 'dense-analysis/ale' 


call plug#end()

""" Colorscheme
set termguicolors
colorscheme onedark

""" Enable syntax
if has("syntax")
	syntax on
endif

""" General settings
set nu
set relativenumber
set so=5
set showmode
set ignorecase
set smartcase
set hlsearch
map <esc> :noh <CR>

""" Enable mouse support
if has("mouse")
	set mouse=a
endif

if has('ide')
  ""  Navigation
  ""map <Leader>q <action>(ActivateProjectToolWindow)
  map <Leader>q :NERDTreeToggle<CR>
  map <Leader>n <action>(NextTab)
  map <Leader>p <action>(PreviousTab)
else
  ""  Navigation
  map <Leader>q :NERDTreeToggle<CR>
  map <Leader>n :bn<CR>
  map <Leader>p :bp<CR>
endif

let &t_ut=''

map <Leader>x :bd<CR>
nnoremap <Leader>w :w<CR>

""" Plugins
let g:ale_sign_error = 'e'
let g:ale_sign_warning = 'w'
let g:ale_virtualtext_cursor = 2
let g:ale_virtualtext_prefix = "    ◆ "
let g:ale_floating_preview = 1
let g:ale_floating_window_border = []
