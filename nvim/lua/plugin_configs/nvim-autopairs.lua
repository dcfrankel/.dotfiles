local M = {}

function M.setup()
  -- Auto close pairs
  vim.pack.add({
    { src = "https://github.com/windwp/nvim-autopairs", name = "nvim-autopairs" }
  })

  require("nvim-autopairs").setup()
end

return M
