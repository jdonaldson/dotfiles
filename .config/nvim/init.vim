
" Default Command overrides
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" These are ergonomic overrides for common vim triggers.  I rely heavily on
" search and leader based triggers, so these get key triggers that are easy to
" hit.

" You need to use the escape key quite often in vim, and on some modern
" keyboards it's a bit uncomfortable to reach.  Ctrl-c works mostly the same
" as escape, and this function makes it perform identically (:h ctrl-c)
inoremap <C-C> <Esc>

" I rely heavily on searching to navigate files (rather than directional
" arrows or word/character movements).  Remap search (/) to m since
" it's a lot easier to hit and I use search movements very often:
nnoremap <space> /
vnoremap <space> /

" The default leader character (;) is also a bit hard to hit, so I use comma.
" http://learnvimscriptthehardway.stevelosh.com/chapters/06.html
let mapleader=","
nnoremap ; :

" Bookmarks for configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" edit my vimrc
nmap <Leader>ev :e $MYVIMRC<CR>
" source my vimrc
nmap <Leader>sv :source $MYVIMRC<CR>
" edit my plugins configuration
nmap <Leader>ep :e ~/.vim/autoload/plugins.vim<CR>

" add vimrc/init.vim/plugins.lua with chezmoi if I change them
autocmd BufWritePost ~/.config/nvim/lua/plugins.lua: !chezmoi add --source-path % <CR>
autocmd BufWritePost $MYVIRMC: !chezmoi add --source-path % <CR>

silent! colorscheme solarized8

"BASIC OPTIONS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" these are the 'simple boolean flag' configurations

set nocompatible
set autowrite
set expandtab    " expand tabs to spaces
set hidden       " hide the old buffer when switching
set lazyredraw
set nowrap       " don't wrap lines
set formatoptions-=t " really don't wrap lines
set number       " always show line numbers
set shiftround   " use multiple of shiftwidth when indenting with '<' and '>'
set smartindent
set title        " change the terminal's title

" Silence
set visualbell   " don't beep
set noerrorbells " no, seriously, don't beep

" Search
set ignorecase   " search : ignore case
set smartcase    " search : smart case
set gdefault     " search : default
set hlsearch     " search : highlight

" Parameter options
set mouse=a         " use mouse in nvich modes
set clipboard+=unnamedplus
set encoding=utf-8
set tw=0
set shell=bash
set undolevels=1000
set ts=4            " a tab is four spaces by default
set sts=4
set sw=4

" Ignore all files like this
set wildignore=*.swp,*.bak,*.pyc,*.class,*.sass-cache,*/_site/*

set splitright "splits go to the right

" autosave on lost focus
au FocusLost * :wa

" give a nice color column that helps show an 80 character width
if exists('+colorcolumn')
  set colorcolumn=80
else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" strip whitespace at end of line
nnoremap <Leader>f$ :%s/\s\+$//<CR>:let @/=''<CR>

" refresh screen
nmap <silent><Leader>ss :redraw!<CR>
" hide highlights from last search
nmap <silent><Leader>sh :nohlsearch<CR>
" Reload current buffer
nnoremap <leader>ee :edit!<cr>



 


"nvim-lspconfig

set undofile " Maintain undo history between sessions

" Require common plugins
source ~/.vim/autoload/plug.vim
source ~/.vim/autoload/plugins.vim

