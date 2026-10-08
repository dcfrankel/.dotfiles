-- Globals
vim.g.mapleader = " " -- Set leader to space-bar

-- General settings
vim.o.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20" -- Block in normal/visual, thin bar in insert, underline in replace
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
vim.o.autoread = true -- Automatically reload file changes
vim.o.laststatus = 2 -- One statusline per window (mirrors Emacs's per-window mode-line)
vim.o.showmode = false -- Hide the "-- INSERT --" indicator; the statusline's mode tag covers this

-- Better regex search
vim.opt.ignorecase = true  -- Ignore case in search patterns
vim.opt.smartcase = true   -- Override 'ignorecase' if the pattern contains upper case characters

-- Better autocomplete settings
vim.o.complete = ".,o" -- use buffer and omnifunc
vim.o.completeopt = "fuzzy,preview,menu,menuone,noselect,popup"
vim.o.autocomplete = true
vim.o.pumheight = 10 -- Cap the completion popup at 10 items
vim.o.pumborder = "rounded"
