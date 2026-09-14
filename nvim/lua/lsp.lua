-- Enable native language servers. Configs live in lsp/*.lua; the servers
-- themselves still need to be installed separately.
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("yamlls")

-- Diagnostics: show the full diagnostic(s) for the current line inline
-- (0.11 virtual_lines), keep gutter signs, and sort by severity.
vim.diagnostic.config({
  virtual_lines = { current_line = true },
  signs = true,
  severity_sort = true,
  underline = true,
})
