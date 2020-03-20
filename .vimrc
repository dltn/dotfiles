" https://github.com/dltn/dotfiles/blob/master/.vimrc

" # Basics

set nocompatible " Disable vi compatibility (stackoverflow.com/a/5845583)
filetype plugin on " Load plugins for specific file types

" # Core remaps
nnoremap zz :update<cr>

" # Look & Feel

syntax on " Enable syntax highlighting
set ruler " Enable ruler (in bottom-right)
set number " Enable line numbers
set cursorline " Highlight the current line
set showmatch " Highlight matching brackets
set incsearch " Search as characters are entered
set hlsearch " Highlight search matches

" # Filesystem

set directory=$HOME/.vim/swp// " Organize swp files in home dir

" # Style

set colorcolumn=80 " Highlight line length 80 ('cc')
" and set it to be gray (not default):
highlight ColorColumn ctermbg=darkgrey guibg=darkgrey

" # Whitespace

" - Set tab defaults to 4 spaces
filetype plugin indent on " Filetype specific indentation rules
set tabstop=4 " Interpret a \t to have a width of 4
set shiftwidth=4 " Set indent size of 4
set expandtab " Expand TABs to spaces

set list listchars=trail:· " Visualize trailing whitespace with a dot

" # vimwiki

" - Diary Navigation Mapping
:nnoremap <leader><Left> :VimwikiDiaryPrevDay<CR>
:nnoremap <leader><Right> :VimwikiDiaryNextDay<CR>

" - Set default vimwiki format to markdown
let g:vimwiki_list = [
\ {
    \ 'path': '~/vimwiki',
    \ 'syntax': 'markdown',
    \ 'ext': '.md'
\ }
\]
