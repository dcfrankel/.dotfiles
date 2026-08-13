local M = {}

function M.setup()
  -- Show git hunks on active buffers
  vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
  })

  require("gitsigns").setup()
end

return M
