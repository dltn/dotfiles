" https://github.com/dltn/dotfiles/blob/master/.vimrc

" == Basics

set nocompatible " https://stackoverflow.com/a/5845583
filetype plugin on " load plugins for specific file types

" == Look & Feel

syntax on " syntax highlighting

" == vimwiki

let g:vimwiki_list = [
\ {
    \ 'path': '~/vimwiki',
    \ 'syntax': 'markdown',
    \ 'ext': '.md'
\ }
\]
