" Require common plugins
source ~/.vim/autoload/plug.vim
source ~/.vim/autoload/plugins.vim

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

" refresh screen
nmap <silent><Leader>ss :redraw!<CR>
" hide highlights from last search
nmap <silent><Leader>sh :nohlsearch<CR>
" Reload current buffer
nnoremap <leader>ee :edit!<cr>

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { "c", "rust" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

require'lspconfig'.pyright.setup{}
EOF


" Telescope
" " Find files using Telescope command-line sugar.
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <leader><space> <cmd>Telescope live_grep<cr>
nnoremap <C-b> <cmd>Telescope buffers<cr>
nnoremap <C-t> <cmd>Telescope help_tags<cr>

 
" vim-commentary
xmap \\  <Plug>Commentary<CR>
nmap \\  <CR><Plug>Commentary
nmap \\\ <Plug>CommentaryLine<CR>
nmap \\u <Plug>CommentaryUndo<CR>


"nvim-lspconfig
lua << EOF
local nvim_lsp = require('lspconfig')
nvim_lsp.pyright.setup{}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright', 'rust_analyzer', 'tsserver' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,

  }
}
end
EOF
