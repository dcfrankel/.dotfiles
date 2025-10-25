local M = {}

function M.setup()
  -- Default LSP configurations
  vim.pack.add({
    { src = 'https://github.com/neovim/nvim-lspconfig', name = "nvim-lspconfig" },
  })
end

return M
