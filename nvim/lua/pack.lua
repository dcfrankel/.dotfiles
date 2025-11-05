local M = {}

function M.load_all()
  vim.pack.add({
    { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
  })
  -- Set theme
  vim.cmd("colorscheme rose-pine")

  -- Load various plugin configurations
  require('plugin_configs.miniclue').setup()
  require('plugin_configs.telescope').setup()
  require('plugin_configs.treesitter').setup()
end

return M
