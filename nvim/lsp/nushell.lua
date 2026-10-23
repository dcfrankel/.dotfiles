-- Sourced from https://github.com/neovim/nvim-lspconfig/blob/master/lsp/nushell.lua
-- The language server is built into nu itself; no separate install needed.
return {
  cmd = { "nu", "--lsp" },
  filetypes = { "nu" },
  root_markers = { ".git" },
}
