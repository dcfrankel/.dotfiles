local M = {}

function M.setup()
  -- Default LSP configurations
  vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master", name = "nvim-treesitter" },
  })

  -- Treesitter default parsers
  require("nvim-treesitter.configs").setup({
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go" },
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,
  })
end

return M
