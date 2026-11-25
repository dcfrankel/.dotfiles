-- Sourced from https://github.com/neovim/nvim-lspconfig/blob/master/lsp/pyrefly.lua
return {
  cmd = { "pyrefly", "lsp" },
  filetypes = { "python" },
  root_markers = {
    "pyrefly.toml",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
}
