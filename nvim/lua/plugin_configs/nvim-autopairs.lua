local M = {}

function M.setup()
  -- map_cr = false: don't let autopairs own <CR>, it just replays a
  -- literal <CR> when the completion popup is visible instead of
  -- accepting the selection. Our own <CR> mapping in keymaps.lua handles it.
  require("nvim-autopairs").setup({ map_cr = false })
end

return M
