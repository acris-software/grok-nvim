-- lua/grok/util.lua
local M = {}
function M.get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  if #lines == 0 then
    return ""
  end
  lines[1] = string.sub(lines[1], s_start[3])
  if n_lines == 1 then
    lines[1] = string.sub(lines[1], 1, s_end[3] - s_start[3] + 1)
  else
    lines[#lines] = string.sub(lines[#lines], 1, s_end[3])
  end
  return table.concat(lines, "\n")
end
return M
