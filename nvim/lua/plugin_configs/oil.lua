local M = {}

function M.setup()
  require("oil").setup({
    default_file_explorer = true, -- Take over directory buffers from netrw
    view_options = { show_hidden = true },
  })
  vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open file explorer" })
end

return M
