-- Sourced from https://github.com/neovim/nvim-lspconfig/blob/master/lsp/helm_ls.lua
return {
  cmd = { "helm_ls", "serve" },
  filetypes = { "helm", "yaml.helm-values" },
  root_markers = { "Chart.yaml" },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = true },
    },
  },
}
