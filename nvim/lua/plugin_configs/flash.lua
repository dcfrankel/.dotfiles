local M = {}

function M.setup()
  -- Better support for jumping to text
  vim.pack.add({
    { src = "https://github.com/folke/flash.nvim", name = "flash" }
  })

  local flash = require("flash")
  vim.keymap.set({"n", "x", "o"}, 's', function() flash.jump() end, { desc = 'FLash' })
  vim.keymap.set({"n", "x", "o"}, 'S', function() flash.treesitter() end, { desc = 'FLash Treesitter' })

end

return M
