local M = {}

function M.setup()
  -- Show git hunks on active bufferfs
  vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
  })

  require("gitsigns")
end

return M
