local M = {}

function M.load_all()
  -- Load some themes
  vim.pack.add({
    { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
    { src = "https://github.com/rebelot/kanagawa.nvim", name = "kanagawa" },
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" }
  })
  -- Set theme
  vim.cmd("colorscheme catppuccin")

  -- Load various plugin configurations
  require("plugin_configs.miniclue").setup()
  require("plugin_configs.telescope").setup()
  require("plugin_configs.treesitter").setup()
  require("plugin_configs.leap").setup()
end

return M
