local M = {}

function M.setup()
  -- Git integration
  vim.pack.add({
    { src = "https://github.com/tpope/vim-fugitive", name = "fugitive" }
  })

end

return M
