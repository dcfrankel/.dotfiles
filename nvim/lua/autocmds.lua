local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Bring the diagnostics popup up on cursor hover, similar to other editors
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = group,
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

-- Buffer-local setup once an LSP client attaches
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true, desc = "Go to definition" })
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, silent = true, desc = "Go to declaration" })
      -- Use the same code action binding as Zed
      vim.keymap.set("n", "g.", vim.lsp.buf.code_action,
        { buffer = bufnr, silent = true, desc = "Open code action menu" })
    end
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
