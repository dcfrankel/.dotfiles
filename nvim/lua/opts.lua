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
