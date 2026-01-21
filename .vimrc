" Show line number on current line, relative numbers elsewhere
set number relativenumber

" Highlight current line
set cursorline

" Turn off old Vi compatibility
set nocompatible

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

" Tab width
set tabstop=2

" Show cursor pos
set ruler

" Display partially typed commands
set showcmd

" Keep 5 lines of context above/below the cursor
set scrolloff=5

" Show whitespace
set list

