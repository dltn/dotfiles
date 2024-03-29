" https://github.com/dltn/dotfiles/blob/master/.vimrc

" # Basics

set nocompatible " Disable vi compatibility (stackoverflow.com/a/5845583)
filetype plugin on " Load plugins for specific file types

" # Core remaps
nnoremap <SPACE> <Nop>
let mapleader=" " " Space key as leader

nnoremap <Leader>s :update<CR> " https://vim.fandom.com/wiki/Quick_save

" # Look & Feel

syntax on " Enable syntax highlighting
set ruler " Enable ruler (in bottom-right)
set number " Enable line numbers
set cursorline " Highlight the current line
set showmatch " Highlight matching brackets
set incsearch " Search as characters are entered
set hlsearch " Highlight search matches
set linebreak " soft wrap on whole words (i.e. not mid-word)

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

" - Insert filename (without path, without extension) as Markdown h1
"   TODO: more proper way to open two lines
nnoremap <Leader>f I# <C-r>=expand("%:t")<cr><Esc>F.d$o<Esc>o

" - Open a timestamped line
nnoremap <Leader>t I<C-r>=strftime("[%H:%M]\n")<cr>

" - Diary Navigation Mapping
:nnoremap <Leader><Left> :VimwikiDiaryPrevDay<CR>
:nnoremap <Leader><Right> :VimwikiDiaryNextDay<CR>

" - Automatically h1 new files
let g:vimwiki_auto_header=1

" - Only use vimwiki in the context of wiki files
let g:vimwiki_global_ext=0

" - Set default vimwiki format to markdown, or use machine specific config
try
    source ~/.vimwiki_list
catch
    let g:vimwiki_list = [
    \ {
        \ 'path': '~/vimwiki',
        \ 'syntax': 'markdown',
        \ 'diary_rel_path': '.',
        \ 'ext': '.md'
    \ }
    \]
endtry

