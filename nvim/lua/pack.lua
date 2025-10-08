local M = {}

local function configure()
    -- Telescope keymaps
    local telescope_builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, { desc = 'Telescope help tags' })
    -- Treesitter default parsers
    require('nvim-treesitter.configs').setup {
        -- A list of parser names, or "all" (the listed parsers MUST always be installed)
        ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go" },
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,
    }


    -- Set theme
    vim.cmd("colorscheme rose-pine")
end

function M.load()
    vim.pack.add({
        -- Required by telescope
        { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
        { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8", name = "telescope" },
        { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
        { src = 'https://github.com/neovim/nvim-lspconfig', name = "nvim-lspconfig" },
        { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = "master", name = "nvim-treesitter" },
    })
    -- Load various plugin configurations
    configure()
    vim.print("Done loading vim.pack plugin configurations.")
end

return M
