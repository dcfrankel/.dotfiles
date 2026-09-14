local M = {}

-- Parsers we always want available (and whose filetypes get highlighting).
local parsers = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go" }

function M.setup()
  -- The `main` branch drops the old `.configs.setup{}`/`ensure_installed`
  -- module system. Instead we install parsers explicitly and turn on
  -- highlighting per-buffer via `vim.treesitter.start()`.
  require("nvim-treesitter").install(parsers)

  local group = vim.api.nvim_create_augroup("UserConfig", { clear = false })

  -- Enable treesitter highlighting (and indentation) for the installed
  -- filetypes. `vim.treesitter.start()` no-ops gracefully without a parser.
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = parsers,
    callback = function()
      pcall(vim.treesitter.start)
      -- Treesitter-based indentation (experimental but handy on main)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })

  -- Rebuild parsers whenever vim.pack updates the treesitter plugin.
  vim.api.nvim_create_autocmd("PackChanged", {
    group = group,
    callback = function(ev)
      local spec = ev.data and ev.data.spec
      if spec and spec.name == "nvim-treesitter" and ev.data.kind == "update" then
        require("nvim-treesitter").update()
      end
    end,
  })
end

return M
