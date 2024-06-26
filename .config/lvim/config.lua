--[[
lv is the global options object
Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

local util = require("util")

-- lvim.format_on_save.enabled = true

-- general
lvim.log.level = "warn"
vim.cmd("set nofoldenable")

local parts = vim.split(os.getenv("COLORSCHEME"):lower(), " ")
lvim.colorscheme = parts[1]
if parts[2] == "dark" then
  vim.cmd("set background=dark")
elseif parts[2] == "light" then
  vim.cmd("set background=light")
end

vim.g.transparent_enabled = true


-- python config
lvim.builtin.dap.active = true




lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('neotest').run.run()<cr>",
  "Test Method" }
lvim.builtin.which_key.mappings["dM"] = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
  "Test Method DAP" }
lvim.builtin.which_key.mappings["df"] = {
  "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" }
lvim.builtin.which_key.mappings["dF"] = {
  "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Class DAP" }
lvim.builtin.which_key.mappings["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" }

lvim.builtin.which_key.mappings["o"] = {
  name = "Ollama",
  c = { "<cmd>:CodeCompanionChat<cr>", "Ollama Chat" },
  r = { "<cmd>!brew services restart ollama<cr>", "Restart Ollama" },
  s = { "<cmd>:CodeCompanion<CR>", "Ollama Chat" }
}


vim.cmd([[cab cc CodeCompanion]])


-- lvim.colorscheme = "lunar"
-- lvim.colorscheme = "tokyonight"
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = ","
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- lvim.keys.normal_mode["<C-b>"] = ":make<cr>"
lvim.keys.normal_mode["<space>"] = "/"
lvim.keys.normal_mode["<C-space>"] = ":Telescope live_grep<cr>"
lvim.keys.normal_mode["<C-p>"] = ":Telescope find_files<cr>"
lvim.keys.normal_mode["<C-g>"] = ":Telescope git_status<cr>"
lvim.keys.normal_mode["\\\\"] = "<Plug>(comment_toggle_linewise_current)"
lvim.keys.normal_mode["<C-n>"] = ":ToggleTerm size=20 direction=horizontal<cr>"
lvim.keys.normal_mode["gv"] = ":vsplit | lua vim.lsp.buf.definition()<CR>"
lvim.keys.normal_mode["+"] = ":vsplit %:h/"

lvim.keys.visual_mode["^S"] = ':ws'

-- lvim.keys.insert_mode["<C-'"] = '<ESC>:ws<CR>i'
lvim.keys.insert_mode["<C-l>"] = '<ESC>:ws<CR>'

lvim.keys.normal_mode["<C-d>"] = "<C-d>zz"
lvim.keys.normal_mode["..."] = ":CodeCompanionActions<CR>"

lvim.keys.normal_mode[";"] = ":"

-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- Change Telescope navigation to use j and k for :setnavigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Change theme settings
-- lvim.builtin.theme.options.dim_inactive = true
-- lvim.builtin.theme.options.style = "storm"

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
-- }

lvim.builtin.which_key.mappings["r"] = {
  name = " Run",
  p = {
    "<cmd>TermExec cmd='python' open=0<CR><cmd>ToggleTermSendCurrentLine<CR><cmd>ToggleTerm<CR>",
    "Python REPL",
  }
}




lvim.builtin.which_key.mappings["t"] = {
  name = "+Telescope",
  f    = { ":Telescope git_files<CR>", "Telescope git_files" },
  c    = { ":Telescope git_commits<CR>", "Telescope git_commits" },
  b    = { ":Telescope git_branches<CR>", "Telescope git_branches" },
  s    = { ":Telescope git_status<CR>", "Telescope git_status" },
  o    = { ":Telescope oldfiles<CR>", "Telescope oldfiles" },
}


lvim.builtin.which_key.mappings["x"] = {
  name = "+Toggle On/Off",
  h = {
    function()
      util.toggle("hlsearch")
    end,
    "Highlight",
  },
  m = { ":MinimapToggle<CR>", "Minimap", },
  n = {
    function()
      util.toggle("relativenumber", true)
    end,
    "Line Numbers",
  },
  s = {
    function()
      util.toggle("spell")
    end,
    "Spelling",
  },
  t = { ":TransparentToggle<CR>", "Transparency" },
  w = {
    function()
      util.toggle("wrap")
    end,
    "Word Wrap",
  },
  c = {
    function()
      local updated = util.update("scrolloff", 999)
      if not updated then
        util.update("scrolloff", 8)
      end
    end,
    "Centered",
  },
}

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "markdown",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true

-- generic LSP settings

-- -- make sure server will always be installed even if the server is in skipped_servers list
lvim.lsp.installer.setup.ensure_installed = {
  "jsonls",
}
-- -- change UI setting of `LspInstallInfo`
-- -- see <https://github.com/williamboman/nvim-lsp-installer#default-configuration>
-- lvim.lsp.installer.setup.ui.check_outdated_servers_on_open = false
-- lvim.lsp.installer.setup.ui.border = "rounded"
-- lvim.lsp.installer.setup.ui.keymaps = {
--     uninstall_server = "d",
--     toggle_server_expand = "o",
-- }

-- ---@usage disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
  { command = "isort", filetypes = { "python" } },
  {
    -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
    command = "prettier",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
    extra_args = { "--print-with", "100" },
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "typescript", "typescriptreact" },
  },
}

-- -- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "ruff", filetypes = { "python" } },
  {
    -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
    command = "shellcheck",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
    extra_args = { "--severity", "warning" },
  },
  {
    command = "codespell",
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "javascript", "python" },
  },
}


-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.json", "*.jsonc" },
--   -- enable wrap mode for json files only
--   command = "setlocal wrap",
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
lvim.plugins = {
  -- { "da-moon/telescope-todgleterm.nvim" },
  { "rinx/nvim-minimap" },
  { "HakonHarnes/img-clip.nvim" },
  { "edluffy/hologram.nvim" },
  { "axelf4/vim-strip-trailing-whitespace" },
  { "rmagatti/auto-session" },
  { "tpope/vim-fugitive" },
  { "brentyi/isort.vim" },
  { "xiyaowong/transparent.nvim" },
  { "MunifTanjim/nui.nvim" },
  { "tpope/vim-vinegar" },
  { "nvim-neotest/nvim-nio" },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
      require("dap-python").setup(mason_path .. "pacakages/debugpy/venv/bin/python")
    end
  },
  {
    "nvim-neotest/neotest",
    config = function()
      -- setup testing
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            -- Extra arguments for nvim-dap configuration
            -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
            dap = {
              justMyCode = false,
              console = "integratedTerminal",
            },
            args = { "--log-level", "DEBUG", "--quiet" },
            runner = "pytest",
          })
        }
      })
    end
  },
  { "nvim-neotest/neotest-python" },
  { "fladson/vim-kitty" },
  -- {'jackMort/ChatGPT.nvim',
  --   config = function()
  --     require("chatgpt").setup()
  --   end,
  -- },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "krivahtoo/silicon.nvim",
    build = "./install.sh"
  },
  -- {"aduros/ai.vim",
  --   config = function()
  --     vim.g["ai_timeout"] = 100
  --   end
  -- },
  { "zchee/vim-flatbuffers" },
  -- {"luk400/vim-jukit"},

  { "neomake/neomake" },
  { "sbdchd/neoformat" },
  { "quarto-dev/quarto-nvim", config = function()
      require 'quarto'.setup()
    end
  },
  {"kylechui/nvim-surround"},
  {"jdonaldson/codecompanion.nvim", config = function()
      require("codecompanion").setup({
        strategies = {
          chat = "ollama",
          inline = "ollama",
        },
        keymaps = {
          ["<C-s>"] = "keymaps.save", -- Save the chat buffer and trigger the API
          ["<C-l>"] = "keymaps.save", -- Save the chat buffer and trigger the API
          ["<C-c>"] = "keymaps.save", -- Save the chat buffer
          ["q"] = "keymaps.cancel_request", -- Cancel the currently streaming request
          ["gc"] = "keymaps.clear", -- Clear the contents of the chat
          ["ga"] = "keymaps.codeblock", -- Insert a codeblock into the chat
          ["gs"] = "keymaps.save_chat", -- Save the current chat
          ["]"] = "keymaps.next", -- Move to the next header in the chat
          ["["] = "keymaps.previous", -- Move to the previous header in the chat
        },
      })
    end
  },
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
    opts = {
      right = {
        { ft = "codecompanion", title = "Code Companion Chat", size = { width = 0.45 } },
      }
    }
  },
  {"huggingface/llm.nvim", config = function()
    require("llm").setup({
      -- model = "starcoder2",
      model = "starcoder2:7b",
      backend = "ollama",
      -- backend = "huggingface",
      -- url = nil,
      url = "http://localhost:11434/api/generate",
      -- cf https://github.com/ollama/ollama/blob/main/docs/api.md#parameters
      tokens_to_clear = { "<|endoftext|>", "<file_sep>"},
      fim = {
        enabled = true,
        file_sep = "<file_sep>",
        prefix = "<fim_prefix>",
        middle = "<fim_middle>",
        suffix = "<fim_suffix>",
      },
      request_body = {
        -- Modelfile options for the model you use
        options = {
          temperature = 0.2,
          top_p = 0.95,
          num_predict = 60,
          stop = {"\nprint", "\n/"}
        }
      },
      enable_suggestions_on_files = {"*.py", "*.qmd", "pyproject.toml"},
    })
  end
  },

  { "stevearc/dressing.nvim"},
  { "tpope/vim-fugitive" },
  -- {"triglav/vim-visual-increment"},
  { "jmbuhr/otter.nvim" },
  -- {"jmbuhr/tmux-kickstarter"},
  -- {"jmbuhr/quarto-nvim-kickstarter"},
  {
    "beauwilliams/focus.nvim",
    config = function()
      require("focus").setup()
    end,
  },
  { "benlubas/molten-nvim" },
  -- COLOR THEMES
  { "tanvirtin/monokai.nvim" },
  { "catppuccin/nvim" },
  { "rebelot/kanagawa.nvim" },
  -- { "ellisonleao/gruvbox.nvim" },
  { "shaunsingh/nord.nvim" },
  { "ericbn/vim-solarized" },
  { "sainnhe/everforest" },
  { "maxmx03/solarized.nvim" },
  { "rainglow/vim" },
}
