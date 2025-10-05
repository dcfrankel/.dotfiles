local pack = {}

local function configure()
    -- Telescope keymaps
    local telescope_builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, { desc = 'Telescope help tags' })

    -- Set theme
    vim.cmd("colorscheme rose-pine")
end

function pack.load()
    vim.pack.add({
        -- Required by telescope
        { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
        { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8", name = "telescope" },
        { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
    })
    -- Load various plugin configurations
    configure()
    vim.print("Done loading vim.pack plugin configurations.")
end

return pack
