local M = {}

function M.setup()
  -- Better commenting functionality
  vim.pack.add({
    { src = "https://github.com/tpope/vim-commentary", name = "commentary" }
  })

end

return M
