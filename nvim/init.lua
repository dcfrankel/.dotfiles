require("opts")
require("keymaps")
require("autocmds")
require("lsp")

-- neovim 0.12+ configs
-- This is mostly for testing/experimentation at this point
if vim.version().minor >= 12 then
  -- Use rounded completion windows
  vim.o.pumborder = "rounded"
  -- Load vim.pack plugins
  require("pack").load_all()
end
