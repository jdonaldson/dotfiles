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

    " Track the engine.
    Plug 'SirVer/ultisnips'
        " Snippets are separated from the engine. Add this if you want them:
        Plug 'honza/vim-snippets'
    Plug 'quangnguyen30192/cmp-nvim-ultisnips'
        
        
    " Install nvim-cmp
    Plug 'hrsh7th/nvim-cmp'
        " Install snippet engine (This example installs [hrsh7th/vim-vsnip](https://github.com/hrsh7th/vim-vsnip))
        Plug 'hrsh7th/vim-vsnip'
        " Install the buffer completion source
        Plug 'hrsh7th/cmp-buffer'
lua <<EOF
        local function check_backspace()
        local col = vim.fn.col(".") - 1
        if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
            return true
        else
            return false
        end
        end

        local function T(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
        end

        local cmp = require("cmp")
        -- local luasnip = require("luasnip")
        -- local lspkind = require("lspkind")

        cmp.setup({

        -- You should change this example to your chosen snippet engine.
        snippet = {
            expand = function(args)
                vim.fn["UltiSnips#Anon"](args.body)
            end,
        },

        completion = {
            completeopt = "menu,menuone,noselect",
            autocomplete = { cmp.TriggerEvent.TextChanged }
        },

        -- You must set mapping.
        mapping = {
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.close(),
            ["<ESC>"] = cmp.mapping.close(),
            ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
            if vim.fn.pumvisible() == 1 then
                vim.fn.feedkeys(T("<C-n>"), "n")
            -- elseif luasnip.expand_or_jumpable() then
            --     vim.fn.feedkeys(T("<Plug>luasnip-expand-or-jump"), "")
            elseif check_backspace() then
                vim.fn.feedkeys(T("<Tab>"), "n")
            else
                fallback()
            end
            end, {
            "i",
            "s",
            }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
            if vim.fn.pumvisible() == 1 then
                vim.fn.feedkeys(T("<C-p>"), "n")
            elseif luasnip.jumpable(-1) then
                vim.fn.feedkeys(T("<Plug>luasnip-jump-prev"), "")
            else
                fallback()
            end
            end, {
            "i",
            "s",
            }),
        },

        formatting = {
            format = function(entry, vim_item)
            -- vim_item.kind = lspkind.presets.default[vim_item.kind] .. " " .. vim_item.kind
            vim_item.menu = ({
                nvim_lsp = "[L]",
                emoji = "[E]",
                path = "[F]",
                calc = "[C]",
                vsnip = "[S]",
                buffer = "[B]",
            })[entry.source.name]
            vim_item.dup = ({
                buffer = 1,
                path = 1,
                nvim_lsp = 0,
            })[entry.source.name] or 0
            return vim_item
            end,
        },

        -- You should specify your *installed* sources.
        sources = {
            { name = "nvim_lsp" },
            { name = "luasnip" },
            -- { name = "nvim_lua" },
            -- { name = "emoji" },
            -- { name = "calc" },
            -- { name = "path" },
            -- { name = "latex_symbols" },
            {
            name = "buffer",
            opts = {
                get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
                end,
            },
            },
        },
        })
EOF


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
            local servers = { 'pyright', 'tsserver' }
            for _, lsp in ipairs(servers) do
            nvim_lsp[lsp].setup {
                on_attach = on_attach,
                flags = {
                    debounce_text_changes = 150,
                }
            }
        end

EOF

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

