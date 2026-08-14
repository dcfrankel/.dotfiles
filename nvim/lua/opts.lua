-- Globals
vim.g.mapleader = " " -- Set leader to space-bar

-- netrw configurations
vim.g.netrw_banner = 0 -- Hide the top banner (removes help text and clutter)
vim.g.netrw_liststyle = 3 -- Set the tree view as default
vim.g.netrw_browse_split = 4 -- Open files in the previous window (keeps the tree sidebar open)
vim.g.netrw_winsize = 20 -- Set the width of the sidebar (percentage of screen)

-- General settings
vim.o.guicursor = "" -- Disable the styled cursor, use a solid block
vim.o.number = true -- Show absolute line numbers
vim.o.relativenumber = true -- Set or disable relative line numbers
vim.o.hlsearch = true -- Enable search highlights
vim.o.incsearch = true -- Jump to matches as you type the search
vim.o.termguicolors = true -- Enable 24-bit true color
vim.o.scrolloff = 8 -- Keep 8 lines of context above/below the cursor
vim.o.expandtab = true -- Expand tabs to spaces
vim.o.tabstop = 4 -- Indentation width = 4 spaces
vim.o.softtabstop = 4 -- Indentation width = 4 spaces
vim.o.shiftwidth = 4 -- Indentation width = 4 spaces
vim.o.smartindent = true -- Auto-indent new lines based on syntax
vim.o.clipboard = "unnamedplus" -- Force yank to copy to the OS clipboard
vim.o.winborder = "rounded" -- Rounded borders on floating windows
vim.o.updatetime = 250 -- Reduce how long to wait for diagnostics window
vim.o.list = true -- Show white space
vim.o.listchars = "tab:» ,lead:•,trail:•" -- Symbols used to render white space

-- Better autocomplete settings
vim.o.complete = ".,o" -- use buffer and omnifunc
vim.o.completeopt = "fuzzy,preview,menu,menuone,noselect,popup"
vim.o.autocomplete = true
vim.o.pumheight = 10 -- Cap the completion popup at 10 items
