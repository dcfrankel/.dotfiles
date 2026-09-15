local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Buffer-local setup once an LSP client attaches
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- Native autocompletion, only for servers that support it
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    -- Buffer-local LSP keymaps (independent of completion support)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true, desc = "Go to definition" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, silent = true, desc = "Go to declaration" })
    -- Use the same code action binding as Zed
    vim.keymap.set("n", "g.", vim.lsp.buf.code_action,
      { buffer = bufnr, silent = true, desc = "Open code action menu" })
  end,
})

-- Open help in a vertical split rather than the default horizontal one
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "help",
  command = "wincmd L",
})

-- Auto open the quickfix window after commands that populate it
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = group,
  pattern = "[^l]*",
  callback = function()
    vim.cmd("cwindow")
  end,
  desc = "Open quickfix window after cgetexpr, vimgrep, make, etc.",
})

-- Keep the netrw tree sidebar (if open) rooted at the current file's directory
local function find_netrw_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "netrw" then
      return win
    end
  end
  return nil
end

-- Guards against the sync below re-triggering itself: restoring focus to the
-- original file window after the deferred sync is a genuine buffer change
-- (we'd left it for the netrw window/buffer), so it fires BufEnter again.
local syncing_netrw = false

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  desc = "Re-root the netrw tree sidebar (if open) at the newly entered file's directory",
  callback = function(ev)
    if syncing_netrw or vim.bo[ev.buf].filetype == "netrw" or vim.bo[ev.buf].buftype ~= "" then
      return
    end

    local filepath = vim.api.nvim_buf_get_name(ev.buf)
    if filepath == "" then
      return
    end

    -- Closing/reopening the sidebar changes the window layout, which some callers
    -- (e.g. Telescope, while it's still unmounting its picker window) don't allow
    -- from within a BufEnter autocmd. Defer it to the next event-loop tick.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) or vim.api.nvim_get_current_buf() ~= ev.buf then
        return
      end

      local netrw_win = find_netrw_win()
      if not netrw_win then
        return
      end

      -- Reusing the sidebar's existing buffer/window via `:Explore <dir>` leaves stale
      -- window-local tree state behind, so close and reopen it with the new directory instead.
      local cur_win = vim.api.nvim_get_current_win()
      local dir = vim.fn.fnamemodify(filepath, ":h")

      syncing_netrw = true
      vim.api.nvim_set_current_win(netrw_win)
      vim.cmd("Lexplore")
      vim.cmd("Lexplore " .. vim.fn.fnameescape(dir))
      vim.api.nvim_set_current_win(cur_win)
      syncing_netrw = false
    end)
  end,
})
