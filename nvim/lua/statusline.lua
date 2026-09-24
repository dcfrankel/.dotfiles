-- Custom statusline
local M = {}

local MODE_HL = {
  n = { tag = "N", hl = "StatuslineModeNormal" },
  i = { tag = "I", hl = "StatuslineModeInsert" },
  ic = { tag = "I", hl = "StatuslineModeInsert" },
  ix = { tag = "I", hl = "StatuslineModeInsert" },
  v = { tag = "V", hl = "StatuslineModeVisual" },
  V = { tag = "V", hl = "StatuslineModeVisual" },
  ["\22"] = { tag = "V", hl = "StatuslineModeVisual" },
  R = { tag = "R", hl = "StatuslineModeReplace" },
  Rv = { tag = "R", hl = "StatuslineModeReplace" },
  no = { tag = "O", hl = "StatuslineModeOperator" },
  nov = { tag = "O", hl = "StatuslineModeOperator" },
  noV = { tag = "O", hl = "StatuslineModeOperator" },
  ["no\22"] = { tag = "O", hl = "StatuslineModeOperator" },
  s = { tag = "S", hl = "StatuslineModeOther" },
  S = { tag = "S", hl = "StatuslineModeOther" },
  ["\19"] = { tag = "S", hl = "StatuslineModeOther" },
  c = { tag = "C", hl = "StatuslineModeOther" },
  cv = { tag = "C", hl = "StatuslineModeOther" },
  ce = { tag = "C", hl = "StatuslineModeOther" },
  t = { tag = "T", hl = "StatuslineModeOperator" },
}

local DIAG_ORDER = {
  { severity = vim.diagnostic.severity.ERROR, label = "E" },
  { severity = vim.diagnostic.severity.WARN, label = "W" },
  { severity = vim.diagnostic.severity.INFO, label = "I" },
  { severity = vim.diagnostic.severity.HINT, label = "H" },
}

local function escape(s)
  return (s:gsub("%%", "%%%%"))
end

local function hl(name, text)
  return "%#" .. name .. "#" .. text
end

local function join(segments)
  local nonempty = {}
  for _, s in ipairs(segments) do
    if s ~= "" then
      table.insert(nonempty, s)
    end
  end
  return table.concat(nonempty, " ○ ")
end

--- Mode tag (e.g. <N>, <I>), colored per mode.
---@return string
local function mode_segment()
  local mode = vim.api.nvim_get_mode().mode
  local entry = MODE_HL[mode]
  if not entry then
    return "<" .. mode .. ">"
  end
  return hl(entry.hl, "<" .. entry.tag .. ">")
end

--- Buffer name with a modified (*) or readonly (%) marker.
---@return string
local function filename_segment()
  local name = vim.fn.expand("%:t")
  if name == "" then
    name = "[No Name]"
  end
  local marker = ""
  if vim.bo.readonly then
    marker = " %"
  elseif vim.bo.modified then
    marker = " *"
  end
  return escape(name) .. marker
end

--- Current gitsigns branch. Empty when not under git.
---@return string
local function branch_segment()
  local dict = vim.b.gitsigns_status_dict
  if not dict or not dict.head or dict.head == "" then
    return ""
  end
  return escape(dict.head)
end

--- Buffer filetype. Empty when unset.
---@return string
local function filetype_segment()
  return vim.bo.filetype
end

--- Attached LSP client names. Empty when none attached.
---@return string
local function lsp_segment()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  return escape(table.concat(names, ","))
end

--- Diagnostic counts by severity (e.g. "E:1 W:2"). Empty when clean.
---@return string
local function diagnostics_segment()
  local counts = vim.diagnostic.count(0)
  local pieces = {}
  for _, entry in ipairs(DIAG_ORDER) do
    local n = counts[entry.severity]
    if n and n > 0 then
      table.insert(pieces, entry.label .. ":" .. n)
    end
  end
  return table.concat(pieces, " ")
end

function M.render()
  -- Ignore netrw buffers since it isn't relevant there
  if vim.bo.filetype == "netrw" then
    return ""
  end
  local left = join({ mode_segment(), filename_segment(), branch_segment() })
  local right = join({ filetype_segment(), lsp_segment(), diagnostics_segment() })
  return " " .. left .. "%=" .. right .. " "
end

function M.setup()
  local bg = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false }).bg

  local groups = {
    StatuslineModeNormal = { fg = "#a6e3a1", bg = bg, bold = true },
    StatuslineModeInsert = { fg = "#89dceb", bg = bg, bold = true },
    StatuslineModeVisual = { fg = "#cba6f7", bg = bg, bold = true },
    StatuslineModeReplace = { fg = "#f38ba8", bg = bg, bold = true },
    StatuslineModeOperator = { fg = "#fab387", bg = bg, bold = true },
    StatuslineModeOther = { fg = "#b4befe", bg = bg, bold = true },
  }

  for name, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, name, opts)
  end

  vim.o.statusline = "%{%v:lua.require('statusline').render()%}"
end

return M
