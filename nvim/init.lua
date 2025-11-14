-- Globals
-- Set leader to space-bar
vim.g.mapleader = " "
vim.g.netrw_liststyle = 3

-- General settings
vim.opt.guicursor = ""
vim.opt.nu = true
-- Set or disable relative line numbers
vim.opt.relativenumber = true
-- Enable search highlights
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
-- Force yank to copy to the OS clipboard
vim.opt.clipboard = "unnamedplus"
vim.o.winborder = "rounded"
-- Reduce how long to wait for diagnostics window
vim.opt.updatetime = 250
-- Show white space
vim.o.list = true
vim.o.listchars = "tab:» ,lead:•,trail:•"
-- Better autocomplete settings
vim.o.complete = ".,o" -- use buffer and omnifunc
vim.o.completeopt = "fuzzy,preview,menu,menuone,noselect,popup"
vim.o.autocomplete = true
vim.o.pumheight = 10

-- Basic keymaps
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- Format a file using lsp
vim.keymap.set("n", "<leader>ff", function() vim.lsp.buf.format() end)
-- Add shortcuts for moving through quickfix (based off of vim-unimpaired)
vim.keymap.set("n", "]q", ":cnext<CR>")
vim.keymap.set("n", "[q", ":cprevious<CR>")
-- Make tab go down and up for completion dropdown
-- Attempted to do this using the lua API but I couldn't get it to work
vim.cmd([[inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"]])
vim.cmd([[inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"]])
-- Clear search highlight using escape (for some reason this isn't a default)
vim.keymap.set("n", "<Esc>", function() vim.cmd("noh") end)

-- LSP configurations should go in lua/lsp/*.lua files
-- Enable native language servers (you still need to install the servers separately)
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")

-- Diagnostics configurations
-- Bring diagnostics popup on cursor hover, similar to other editors
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = function(_)
    vim.diagnostic.open_float(nil, { focusable = false })
  end
})

-- Specific setup actions for LSP buffers
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bufnr = ev.buf                                       -- Get the buffer local
    local client = vim.lsp.get_client_by_id(ev.data.client_id) -- Get the LSP client
    if client:supports_method("textDocument/completion") then
      -- Enable native completion using LSP
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      -- Configure gd and gD to act as you'd expect
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true, desc = "Go to definition" })
      vim.keymap.set("n", "gD", vim.lsp.buf.definition, { buffer = bufnr, silent = true, desc = "Go to definition" })
      -- Use the same code action binding as Zed
      vim.keymap.set("n", "g.", vim.lsp.buf.code_action,
        { buffer = bufnr, silent = true, desc = "Open code action menu" })
    end
  end,
})

-- Open help in vertical split rather the the default horizontal
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  command = "wincmd L",
})

-- Auto open quickfix for certain actions
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "[^l]*",
  callback = function()
    vim.cmd("cwindow")
  end,
  desc = "Open quickfix window after cgetexpr, vimgrep, make, etc.",
})

-- neovim .12 configs
-- This is mostly for testing/experimientation at this point
if vim.version().minor >= 12 then
  -- Use rounded completion windows
  vim.o.pumborder = "rounded"
  -- Load vim.pack plugins
  local pack = require("pack")
  pack.load_all()
end
