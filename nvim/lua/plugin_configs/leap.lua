local M = {}

function M.setup()
  vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Leap" })
  vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Leap window" })
end

return M
