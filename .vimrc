" https://github.com/dltn/dotfiles/blob/master/.vimrc

" # Basics

set nocompatible " Disable vi compatibility (https://stackoverflow.com/a/5845583)
filetype plugin on " Load plugins for specific file types

" # Look & Feel

syntax on " Enable syntax highlighting

" # vimwiki

" - Set default vimwiki format to markdown
let g:vimwiki_list = [
\ {
    \ 'path': '~/vimwiki',
    \ 'syntax': 'markdown',
    \ 'ext': '.md'
\ }
\]
