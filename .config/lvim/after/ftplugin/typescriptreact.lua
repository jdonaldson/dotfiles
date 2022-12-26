local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    exe = "prettier",
    filetypes = { "typescriptreact" },
    args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
  }
}
