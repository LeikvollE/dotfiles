set nocompatible

""" Map leader to space
let mapleader = " "

""" Plugins
call plug#begin()

Plug 'rafi/awesome-vim-colorschemes'
Plug 'wincent/terminus'
Plug 'vimpostor/ale', { 'branch': 'virt_all' }

call plug#end()

""" Colorscheme
let &t_ut=''
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
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

map <Leader>x :bd<CR>
nnoremap <Leader>w :w<CR>

""" Plugins
let g:ale_sign_error = 'e'
let g:ale_sign_warning = 'w'
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = "    ◆ "
let g:ale_floating_preview = 1
let g:ale_floating_window_border = []
