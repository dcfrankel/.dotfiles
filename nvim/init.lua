-- Set leader to space-bar
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

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
-- Better autocommplete settings
vim.o.complete = ".,o" -- use buffer and omnifunc
vim.o.completeopt = "fuzzy,preview,menu,menuone,noselect,popup"
vim.o.autocomplete = true
vim.o.pumheight = 10

-- Enable native LSP configurations (you still need to install the servers separately)
-- Lua language server configurations for neovim dev
vim.lsp.config('luals', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      }
    }
  },
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath('config')
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
        }
      }
    })
  end
})

-- Enable LSP servers
vim.lsp.enable({'luals', 'gopls'})

-- Enable virtual lines for diagnostics
vim.diagnostic.config({virtual_lines = true})

-- Specific setup actions for LSP buffers
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local bufnr = ev.buf -- Get the buffer
    local client = vim.lsp.get_client_by_id(ev.data.client_id) -- Get the LSP client
    if client:supports_method('textDocument/completion') then
      -- Enable native completion using LSP
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    -- Configure gd and gD to act as you'd expect
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true })
    vim.keymap.set("n", "gD", vim.lsp.buf.definition, { buffer = bufnr, silent = true })
    -- Use the same code action binding as Zed
    vim.keymap.set("n", "g.", vim.lsp.buf.code_action, { buffer = bufnr, silent = true })
    end
  end,
})

-- neovim .12 configs
-- This is mostly for testing/experimientation at this point
if  vim.version().minor >= 12 then
    -- Use rounded completion windows
    vim.o.pumborder = 'rounded'
    -- Load vim.pack plugins
    local pack = require("pack")
    pack.load()
end
