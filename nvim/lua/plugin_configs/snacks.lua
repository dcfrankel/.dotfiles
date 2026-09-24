local M = {}

-- Map the CarGurus GitHub Enterprise host to the same URL shape as github.com
local gitbrowse_url_patterns = {
  ["code%.cargurus%.com"] = {
    branch = "/tree/{branch}",
    file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
    permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
    commit = "/commit/{commit}",
  },
}

local function copy_git_link()
  Snacks.gitbrowse({
    what = "permalink",
    notify = false,
    url_patterns = gitbrowse_url_patterns,
    open = function(url)
      vim.fn.setreg("+", url)
      Snacks.notify(url, { title = "Git link copied" })
    end,
  })
end

function M.setup()
  require("snacks").setup({
    picker = {
      matcher = {
        frecency = true, -- boost frequently/recently picked items in rankings
      },
    },
  })

  local picker = Snacks.picker
  vim.keymap.set("n", "<leader>p", picker.files, { desc = "Snacks find files (fuzzy, by name)" })
  vim.keymap.set("n", "<leader>f", picker.grep, { desc = "Snacks live grep (fuzzy content search)" })
  vim.keymap.set("n", "<leader>b", picker.buffers, { desc = "Snacks buffers (fuzzy switch)" })
  vim.keymap.set("n", "<leader>?", picker.help, { desc = "Snacks help tags" })
  vim.keymap.set({ "n", "x" }, "<leader>gl", copy_git_link, { desc = "Copy git permalink to clipboard" })
end

return M
