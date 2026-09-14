local M = {}

function M.load_all()
  -- Declare every plugin in one place. Each plugin_configs module below only
  -- configures its plugin; installation/versioning lives here.
  vim.pack.add({
    -- Themes
    { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
    { src = "https://github.com/rebelot/kanagawa.nvim", name = "kanagawa" },
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

    -- Fuzzy finder + its dependency
    { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8", name = "telescope" },
    { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },

    -- Treesitter (main branch: new setup/install API)
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main", name = "nvim-treesitter" },

    -- Editing / navigation helpers
    { src = "https://github.com/ggandor/leap.nvim", name = "leap" },
    { src = "https://github.com/windwp/nvim-autopairs", name = "nvim-autopairs" },
    { src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
    { src = "https://github.com/nvim-mini/mini.clue", version = "stable", name = "mini.clue" },
  })

  -- Set theme
  vim.cmd("colorscheme catppuccin")

  -- Load various plugin configurations
  require("plugin_configs.miniclue").setup()
  require("plugin_configs.telescope").setup()
  require("plugin_configs.treesitter").setup()
  require("plugin_configs.leap").setup()
  require("plugin_configs.nvim-autopairs").setup()
  require("plugin_configs.gitsigns").setup()
end

return M
