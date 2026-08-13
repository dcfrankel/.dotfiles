-- Open the file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer" })
-- Format the current buffer using the LSP
vim.keymap.set("n", "<leader>ff", vim.lsp.buf.format, { desc = "Format buffer" })
-- Move through the quickfix list (based off of vim-unimpaired)
vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", ":cprevious<CR>", { desc = "Previous quickfix item" })
-- Make Tab/S-Tab cycle the completion popup, or fall back to a literal tab
vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })
-- Clear search highlight with escape (not a default)
vim.keymap.set("n", "<Esc>", vim.cmd.nohlsearch, { desc = "Clear search highlight" })
-- Make escape return to normal mode from terminal mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
