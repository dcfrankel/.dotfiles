" Most basic configs
set encoding=utf-8
set incsearch " Show partial search matches
set ignorecase " Ignore search cases 
set wildmenu " Tab completion for menus
set hlsearch " Highlight searches
set number relativenumber " Show relative line numbers
set ruler " Show line number and column at bottom
set scrolloff=1 " When to start showing text when scrolling
set laststatus=2
set backspace=indent,eol,start " Allow backspace to work as expected
set undofile " Keep undo history after closing
set belloff=all
set nocompatible
set noshowmode
set autoindent
set splitbelow
set splitright
syntax on


" ===== Plugins =====
call plug#begin(stdpath('data') . '/plugged')
" Generally useful plugins
Plug 'jiangmiao/auto-pairs'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
call plug#end()
