-- Globals
-- Set leader to space-bar
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.g.netrw_liststyle = 3

-- General settings
vim.opt.guicursor = ""
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.o.winborder = 'rounded'
-- Show white space
vim.o.list = true
vim.o.listchars = 'tab:» ,lead:•,trail:•'
-- Better autocomplete settings
vim.o.complete = ".,o" -- use buffer and omnifunc
vim.o.completeopt = "fuzzy,preview,menu,menuone,noselect,popup"
vim.o.autocomplete = true
vim.o.pumheight = 10

-- LSP configurations should go in lua/lsp/*.lua files
-- Enable native language servers (you still need to install the servers separately)
vim.lsp.enable('lua_ls')
vim.lsp.enable('gopls' )

-- Enable virtual lines for diagnostics
vim.diagnostic.config({ virtual_lines = true })

-- Specific setup actions for LSP buffers
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local bufnr = ev.buf                                 -- Get the buffer local
    local client = vim.lsp.get_client_by_id(ev.data.client_id) -- Get the LSP client
    if client:supports_method('textDocument/completion') then
      -- Enable native completion using LSP
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      -- Configure gd and gD to act as you'd expect
      vim.keymap.set("n", "gd", vim.lsp.buf.definition,
        { buffer = bufnr, silent = true, desc = "Go to definition" })
      vim.keymap.set("n", "gD", vim.lsp.buf.definition,
        { buffer = bufnr, silent = true, desc = "Go to definition" })
      -- Use the same code action binding as Zed
      vim.keymap.set("n", "g.", vim.lsp.buf.code_action,
        { buffer = bufnr, silent = true, desc = "Open code action menu" })
    end
  end,
})

-- neovim .12 configs
-- This is mostly for testing/experimientation at this point
if vim.version().minor >= 12 then
  -- Use rounded completion windows
  vim.o.pumborder = 'rounded'
  -- Load vim.pack plugins
  local pack = require("pack")
  pack.load_all()
end
