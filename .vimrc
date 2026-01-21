" Turn off old Vi compatibility
set nocompatible

" Show line number on current line, relative numbers elsewhere
set number relativenumber

" Highlight current line
set cursorline

" Switch from a modified buffer without saving
set hidden

" Mod backspace to delete over autoindent, across breaks, back past insert pos
set backspace=indent,eol,start

" Enable mouse support
set mouse=a

" Make searches case-insensitive by default
set ignorecase

" Override ignorecase when search contains uppercase
set smartcase

" Show matches during search
set incsearch

" Highlight all matches
set hlsearch

" Clear highlight with double-esc
nnoremap <Esc><Esc> :nohlsearch<CR>

" Wrap search
set wrapscan

" New lines inherit indentation
set autoindent

" Basic indentation rules
set smartindent

" Display tab columns
set tabstop=2

" Use tabs (not spaces)
set noexpandtab

" Indent operations shift by 2 cols
set shiftwidth=2

" Make <Tab> in insert mode insert a real tab
set softtabstop=0

" Ensure indentation prefers tabs when possible
set smarttab

" Show cursor pos
set ruler

" Display partially typed commands
set showcmd

" Keep 5 lines of context above/below the cursor
set scrolloff=5

" Show whitespace
set list

" Syntax highlighting
syntax on

" Use dark background
set background=dark

" Jump to last pos when reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Load indentation rules and plugins
filetype plugin indent on

