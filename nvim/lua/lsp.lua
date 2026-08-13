-- Enable native language servers. Configs live in lsp/*.lua; the servers
-- themselves still need to be installed separately.
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("yamlls")
