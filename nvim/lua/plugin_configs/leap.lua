local M = {}

function M.setup()
  -- Better support for jumping to text
  vim.pack.add({
    { src = "https://github.com/ggandor/leap.nvim", name = "leap" }
  })

  require("leap")
  vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)', { desc = "Leap" })
  vim.keymap.set('n', 'S', '<Plug>(leap-from-window)', { desc = "Leap window" })
end

return M
