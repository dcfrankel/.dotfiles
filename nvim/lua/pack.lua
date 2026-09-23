local M = {}

function M.load_all()
  -- Declare every plugin in one place. Each plugin_configs module below only
  -- configures its plugin; installation/versioning lives here.
  vim.pack.add({
    -- Themes
    { src = "https://github.com/rose-pine/neovim", version = "ff483051a47e27d84bdef47703538df1ed9f4a47", name = "rose-pine" },
    { src = "https://github.com/rebelot/kanagawa.nvim", version = "bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3", name = "kanagawa" },
    { src = "https://github.com/catppuccin/nvim", version = "edefef779ab08ce1a4a404713e3012b0d202bd35", name = "catppuccin" },

    -- Fuzzy finder / picker
    { src = "https://github.com/folke/snacks.nvim", version = "882c996cf28183f4d63640de0b4c02ec886d01f2", name = "snacks" },

    -- Treesitter (pinned snapshot of main: new setup/install API)
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "9a168f6357ed21c3a636e1727bc7d382abc451b8", name = "nvim-treesitter" },

    -- Editing / navigation helpers
    { src = "https://github.com/ggandor/leap.nvim", version = "cbb7d3e4d9584d6b1ae47932f894eb4a16197a52", name = "leap" },
    { src = "https://github.com/windwp/nvim-autopairs", version = "430522f95fe4fb7c511ec64f8c1a90cc6a66c05c", name = "nvim-autopairs" },
    { src = "https://github.com/lewis6991/gitsigns.nvim", version = "fd36f038e52ad8409fbf9926ae4a0a514cca04d8", name = "gitsigns" },
    { src = "https://github.com/nvim-mini/mini.clue", version = "62e9e38c3dc4b7d429f1b6e28d96f96cdff71132", name = "mini.clue" },

    -- Language-specific
    { src = "https://github.com/mfussenegger/nvim-jdtls", version = "6e9d953f0b82bccdb834cfde0e893f3119c22592", name = "nvim-jdtls" },
  })

  -- Set theme
  vim.cmd("colorscheme catppuccin")

  -- Load various plugin configurations
  require("plugin_configs.miniclue").setup()
  require("plugin_configs.snacks").setup()
  require("plugin_configs.treesitter").setup()
  require("plugin_configs.leap").setup()
  require("plugin_configs.nvim-autopairs").setup()
  require("plugin_configs.gitsigns").setup()
  require("plugin_configs.jdtls").setup()
  require("statusline").setup()
end

return M
