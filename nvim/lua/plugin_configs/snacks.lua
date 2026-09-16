local M = {}

function M.setup()
  require("snacks").setup({
    picker = {
      matcher = {
        frecency = true, -- boost frequently/recently picked items in rankings
      },
    },
  })

  local picker = Snacks.picker
  vim.keymap.set("n", "<leader>p", picker.files, { desc = "Snacks find files (fuzzy, by name)" })
  vim.keymap.set("n", "<leader>f", picker.grep, { desc = "Snacks live grep (fuzzy content search)" })
  vim.keymap.set("n", "<leader>b", picker.buffers, { desc = "Snacks buffers (fuzzy switch)" })
  vim.keymap.set("n", "<leader>h", picker.help, { desc = "Snacks help tags" })
end

return M
