local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({ { exe = "goimports", filetypes = { "go" } } })
