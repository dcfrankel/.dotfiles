return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      -- globPattern is quite expensive; cap it to avoid scanning unrelated trees
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
}
