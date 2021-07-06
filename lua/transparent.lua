local M = {}
local vim = vim

local config = {
  enable = false,
  groups = {
    "Normal",
    "Comment",
    "Constant",
    "Special",
    "Identifier",
    "Statement",
    "PreProc",
    "Type",
    "Underlined",
    "Todo",
    "String",
    "Function",
    "Conditional",
    "Repeat",
    "Operator",
    "Structure",
    "LineNr",
    "NonText",
    "SignColumn",
    "CursorLineNr",
    "EndOfBuffer",
  },
  extra_groups = {},
  exclude = {},
}

local clear_group_bg = function(group, highlights)
  if group then
    if config.exclude[group] or vim.fn.highlight_exists(group) == 0 then
      return
    end
    if not highlights then
      highlights = vim.api.nvim_exec("highlight " .. group, true)
    end
  else
    if highlights then
      group = vim.split(highlights, " ")[1]
    else
      return
    end
  end

  if config.exclude[group] then
    return
  end

  if highlights:match("links to") then
    return
  end

  local term = highlights:match([[term=([%w#]+)]]) or "NONE"
  local ctermfg = highlights:match([[ctermfg=([%w#]+)]]) or "NONE"
  local gui = highlights:match([[gui=([%w#]+)]]) or "NONE"
  local guifg = highlights:match([[guifg=([%w#]+)]]) or "NONE"
  vim.cmd(
    string.format(
      "hi %s term=%s ctermfg=%s ctermbg=NONE gui=%s guifg=%s guibg=NONE",
      group,
      term,
      ctermfg,
      gui,
      guifg
    )
  )
end

function M.clear_bg()
  if vim.g.transparent_enabled ~= 1 then
    return
  end

  for _, group in ipairs(config.groups) do
    clear_group_bg(group)
  end

  if type(config.extra_groups) == "string" then
    if config.extra_groups == "all" then
      local hls = vim.split(vim.api.nvim_exec("highlight", true), "\n")
      for _, hl in ipairs(hls) do
        clear_group_bg(nil, hl)
      end
    else
      clear_group_bg(config.extra_groups)
    end
  else
    for _, group in ipairs(config.extra_groups) do
      clear_group_bg(group)
    end
  end
end

function M.toggle_transparent(option)
  if option == 0 then
    vim.g.transparent_enabled = 0
  elseif option == 1 then
    vim.g.transparent_enabled = 1
  else
    vim.g.transparent_enabled = vim.g.transparent_enabled == 0 and 1 or 0
  end
  vim.cmd("colorscheme " .. vim.g.colors_name)
end

function M.setup(user_config)
  config = vim.tbl_extend("force", config, user_config)
  -- convert exclude to a map
  local map = {}
  for _, g in ipairs(config.exclude) do
    map[g] = g
  end
  config.exclude = map

  if vim.g.transparent_enabled == nil then
    vim.g.transparent_enabled = config.enable and 1 or 0
  end
end

return M
