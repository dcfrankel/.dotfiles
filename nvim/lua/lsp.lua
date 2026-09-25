-- Helm charts are plain YAML wrapped in Go templates. Give template files
-- their own filetype so only helm_ls attaches (it shells out to
-- yaml-language-server itself for those), while values files get a
-- compound filetype so both yamlls and helm_ls attach.
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/NOTES%.txt"] = "helm",
    [".*values.*%.ya?ml"] = "yaml.helm-values",
  },
})

-- Enable native language servers. Configs live in lsp/*.lua; the servers
-- themselves still need to be installed separately.
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("yamlls")
vim.lsp.enable("helm_ls")
vim.lsp.enable("bashls")

-- Diagnostics: show the full diagnostic(s) for the current line inline
-- (0.11 virtual_lines), keep gutter signs, and sort by severity.
vim.diagnostic.config({
  virtual_lines = { current_line = true },
  signs = true,
  severity_sort = true,
  underline = true,
})
