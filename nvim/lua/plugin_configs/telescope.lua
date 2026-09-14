local M = {}

function M.setup()
  -- Fuzzy searching
  vim.pack.add({
    { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8", name = "telescope" },
    -- Telescope dependency
    { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
  })

  -- Telescope keymaps
  local telescope_builtin = require("telescope.builtin")
  vim.keymap.set("n", "<leader>tf", telescope_builtin.find_files, { desc = "Telescope find files" })
  vim.keymap.set("n", "<leader>tg", telescope_builtin.live_grep, { desc = "Telescope live grep" })
  vim.keymap.set("n", "<leader>tb", telescope_builtin.buffers, { desc = "Telescope buffers" })
  vim.keymap.set("n", "<leader>th", telescope_builtin.help_tags, { desc = "Telescope help tags" })

  -- Single-key mnemonics matching the emacs consult leader bindings
  vim.keymap.set("n", "<leader>p", telescope_builtin.find_files, { desc = "Telescope find files (fuzzy, by name)" })
  vim.keymap.set("n", "<leader>f", telescope_builtin.live_grep, { desc = "Telescope live grep (fuzzy content search)" })
  vim.keymap.set("n", "<leader>b", telescope_builtin.buffers, { desc = "Telescope buffers (fuzzy switch)" })
end

return M
