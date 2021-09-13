call plug#begin('~/.vim/plugged')
    " color
    Plug  'lifepillar/vim-solarized8'

    " finding stuff
    Plug 'nvim-telescope/telescope.nvim'
        Plug 'nvim-lua/plenary.nvim'
        " Telescope
        " " Find files using Telescope command-line sugar.
        nnoremap <C-p> <cmd>Telescope find_files<cr>
        nmap <Leader><space> <cmd>Telescope live_grep<cr>
        nnoremap <C-b> <cmd>Telescope buffers<cr>
        nnoremap <C-t> <cmd>Telescope help_tags<cr>

    " syntax highlighting
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
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
        }}
EOF


    " lsp config base
    Plug 'neovim/nvim-lspconfig'
        lua require'lspconfig'.pyright.setup{}

    " statusbar and gutter stuff
    Plug 'hoob3rt/lualine.nvim',
        Plug 'kyazdani42/nvim-web-devicons'
        Plug 'ryanoasis/vim-devicons'
        lua require('lualine').setup{options = {theme = 'solarized_dark'}}

    Plug 'airblade/vim-gitgutter'

    " Tim Pope's excellent hacks
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-commentary'
        " vim-commentary
        xmap \\  <Plug>Commentary<CR>
        nmap \\  <CR><Plug>Commentary
        nmap \\\ <Plug>CommentaryLine<CR>
        nmap \\u <Plug>CommentaryUndo<CR>



    " Language stuff
    Plug 'tpope/vim-markdown'


call plug#end()

