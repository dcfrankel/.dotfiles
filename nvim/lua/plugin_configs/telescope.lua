local M = {}

function M.setup()
  -- Fuzzy searching
  vim.pack.add({
    { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8", name = "telescope" },
    -- Telescope dependency
    { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
  })

  -- Telescope keymaps
  local telescope_builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Telescope find files' })
  vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, { desc = 'Telescope buffers' })
  vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, { desc = 'Telescope help tags' })
end

return M
