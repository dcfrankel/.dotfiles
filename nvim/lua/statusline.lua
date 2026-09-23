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
  { severity = vim.diagnostic.severity.ERROR, label = "E", hl = "StatuslineDiagError" },
  { severity = vim.diagnostic.severity.WARN, label = "W", hl = "StatuslineDiagWarn" },
  { severity = vim.diagnostic.severity.INFO, label = "I", hl = "StatuslineDiagInfo" },
  { severity = vim.diagnostic.severity.HINT, label = "H", hl = "StatuslineDiagHint" },
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
  return table.concat(nonempty, hl("StatuslineSep", " ○ "))
end

--- Mode tag (e.g. <N>, <I>), colored per mode.
---@return string
local function mode_segment()
  local mode = vim.api.nvim_get_mode().mode
  local entry = MODE_HL[mode]
  if not entry then
    return hl("StatuslineText", "<" .. mode .. ">")
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
  return hl("StatuslineFilename", escape(name)) .. hl("StatuslineMarker", marker)
end

--- Current gitsigns branch. Empty when not under git.
---@return string
local function branch_segment()
  local dict = vim.b.gitsigns_status_dict
  if not dict or not dict.head or dict.head == "" then
    return ""
  end
  return hl("StatuslineBranch", escape(dict.head))
end

--- Buffer filetype. Empty when unset.
---@return string
local function filetype_segment()
  local ft = vim.bo.filetype
  if ft == "" then
    return ""
  end
  return hl("StatuslineFiletype", ft)
end

--- Attached LSP client names, colored per health. Empty when none attached.
---@return string
local function lsp_segment()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  local names = {}
  local all_healthy = true
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
    if client:is_stopped() then
      all_healthy = false
    end
  end
  local group = all_healthy and "StatuslineLsp" or "StatuslineDiagWarn"
  return hl(group, escape(table.concat(names, ",")))
end

--- Diagnostic counts by severity (e.g. "E:1 W:2"). Empty when clean.
---@return string
local function diagnostics_segment()
  local counts = vim.diagnostic.count(0)
  local pieces = {}
  for _, entry in ipairs(DIAG_ORDER) do
    local n = counts[entry.severity]
    if n and n > 0 then
      table.insert(pieces, hl(entry.hl, entry.label .. ":" .. n))
    end
  end
  if #pieces == 0 then
    return ""
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
  local palette = require("catppuccin.palettes").get_palette()

  local groups = {
    StatuslineModeNormal = { fg = palette.green, bold = true },
    StatuslineModeInsert = { fg = palette.sky, bold = true },
    StatuslineModeVisual = { fg = palette.mauve, bold = true },
    StatuslineModeReplace = { fg = palette.red, bold = true },
    StatuslineModeOperator = { fg = palette.peach, bold = true },
    StatuslineModeOther = { fg = palette.lavender, bold = true },
    StatuslineText = { fg = palette.text, bold = true },
    StatuslineFilename = { fg = palette.text, bold = true },
    StatuslineMarker = { fg = palette.red },
    StatuslineBranch = { fg = palette.peach },
    StatuslineFiletype = { fg = palette.blue, bold = true },
    StatuslineLsp = { fg = palette.sky },
    StatuslineSep = { fg = palette.overlay0 },
    StatuslineDiagError = { fg = palette.red },
    StatuslineDiagWarn = { fg = palette.yellow },
    StatuslineDiagInfo = { fg = palette.blue },
    StatuslineDiagHint = { fg = palette.overlay1 },
  }

  for name, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, name, opts)
  end

  vim.o.statusline = "%{%v:lua.require('statusline').render()%}"
end

return M
