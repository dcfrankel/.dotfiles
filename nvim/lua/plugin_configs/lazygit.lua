local M = {}

function M.setup()
  -- lazygit.nvim needs no setup(). Merge an nvim-only overlay onto the base
  -- config so `o` opens files in this Neovim instead of the OS default app.
  local lg_dir = vim.fn.expand("~/.dotfiles/lazygit")
  vim.g.lazygit_use_custom_config_file_path = 1
  vim.g.lazygit_config_file_path = { lg_dir .. "/config.yaml", lg_dir .. "/nvim.yaml" }

  vim.keymap.set("n", "<leader>gg", "<CMD>LazyGit<CR>", { desc = "Open LazyGit" })

  -- The global terminal-mode <Esc> -> <C-\><C-n> mapping (keymaps.lua) steals
  -- Escape from lazygit; send it through to lazygit in its buffer instead.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "lazygit",
    desc = "Pass <Esc> through to lazygit",
    callback = function(args)
      vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = args.buf, nowait = true, desc = "Send Esc to lazygit" })
    end,
  })
end

return M
