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

-- Rewrite a multi-term query into a PCRE2 pattern so terms match in any order
-- (like consult + orderless). `!term` excludes lines containing term. The
-- \G...\K tail makes rg report each term as its own match for highlighting.
---@param query string whitespace-separated search terms
---@return string? pattern PCRE2 pattern, or nil if the query needs no rewrite
local function orderless_pattern(query)
  local positive, lookaheads = {}, {}
  for term in query:gmatch("%S+") do
    local negated = term:match("^!(.+)$")
    if negated then
      lookaheads[#lookaheads + 1] = ("(?!.*?(?:%s))"):format(negated)
    else
      positive[#positive + 1] = ("(?:%s)"):format(term)
      lookaheads[#lookaheads + 1] = ("(?=.*?%s)"):format(positive[#positive])
    end
  end
  if #lookaheads < 2 or #positive == 0 then
    return nil
  end
  return ("(?:^%s|\\G(?!^)).*?\\K(?:%s)"):format(table.concat(lookaheads), table.concat(positive, "|"))
end

---@param opts snacks.picker.grep.Config
---@param ctx snacks.picker.finder.ctx
---@return snacks.picker.finder.result
local function orderless_grep(opts, ctx)
  local grep = require("snacks.picker.source.grep").grep
  -- Preserve snacks' optional "query -- <rg args>" suffix
  local query, rg_args = ctx.filter.search:match("^(.-)(%s+%-%-%s*.*)$")
  local pattern = orderless_pattern(query or ctx.filter.search)
  if not pattern then
    return grep(opts, ctx)
  end
  local filter = ctx.filter:clone()
  filter.search = pattern .. (rg_args or "")
  opts = vim.tbl_extend("force", {}, opts, { args = vim.list_extend({ "--pcre2" }, opts.args or {}) })
  -- Don't mutate ctx.filter: the finder compares its search to detect changes
  return grep(opts, setmetatable({ filter = filter }, { __index = ctx }))
end

function M.setup()
  require("snacks").setup({
    picker = {
      matcher = {
        frecency = true, -- boost frequently/recently picked items in rankings
      },
      sources = {
        grep = { finder = orderless_grep },
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
