-- Globals
-- Set leader to space-bar
vim.g.mapleader = " "

-- netrw configurations
-- Hide the top banner (removes help text and clutter)
vim.g.netrw_banner = 0
-- Set the tree view as default
vim.g.netrw_liststyle = 3
-- Open files in the previous window (keeps the tree sidebar open)
vim.g.netrw_browse_split = 4
-- Set the width of the sidebar (percentage of screen)
vim.g.netrw_winsize = 20

-- General settings
vim.o.guicursor = ""
vim.o.number = true
-- Set or disable relative line numbers
vim.o.relativenumber = true
-- Enable search highlights
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.termguicolors = true
vim.o.scrolloff = 8
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true
-- Force yank to copy to the OS clipboard
vim.o.clipboard = "unnamedplus"
vim.o.winborder = "rounded"
-- Reduce how long to wait for diagnostics window
vim.o.updatetime = 250
-- Show white space
vim.o.list = true
vim.o.listchars = "tab:» ,lead:•,trail:•"
-- Better autocomplete settings
vim.o.complete = ".,o" -- use buffer and omnifunc
vim.o.completeopt = "fuzzy,preview,menu,menuone,noselect,popup"
vim.o.autocomplete = true
vim.o.pumheight = 10
