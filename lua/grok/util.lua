-- ~/github.com/acris-software/grok-nvim/lua/grok/util.lua

local M = {}
local log = require("grok.log")

function M.get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  if #lines == 0 then
    log.debug("No visual selection found")
    return ""
  end
  lines[1] = string.sub(lines[1], s_start[3])
  if n_lines == 1 then
    lines[1] = string.sub(lines[1], 1, s_end[3] - s_start[3] + 1)
  else
    lines[#lines] = string.sub(lines[#lines], 1, s_end[3])
  end
  local selection = table.concat(lines, "\n")
  log.debug("Visual selection: " .. selection)
  return selection
end

function M.get_model_max_tokens(model)
  local max_tokens = {
    ["grok-3-mini"] = 131072,
  }
  return max_tokens[model] or 131072
end

function M.get_model_max_chars(model_chars)
  local max_chars = {
    ["grok-3-mini"] = 2000,
  }
  return max_chars[model_chars] or 2000
end

function M.validate_config(opts)
  if
    type(opts.prompt_position) ~= "string" or not vim.tbl_contains({ "left", "center", "right" }, opts.prompt_position)
  then
    vim.notify(
      "Invalid prompt_position: must be 'left', 'center', or 'right'. Defaulting to 'center'.",
      vim.log.levels.WARN
    )
    opts.prompt_position = "center"
  end
end

function M.auto_scroll(buf, win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_cursor(win, { line_count, 0 })
end

function M.create_floating_input(opts)
  local config = require("grok").config
  local max_length = M.get_model_max_tokens(config.model)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.6)
  local height = 3
  local row = math.floor(vim.o.lines - height - 2) -- Bottom-aligned, 2 lines from edge
  local col = math.floor((vim.o.columns - width) / 2) -- Centered horizontally
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = "Enter Query (0/" .. max_length .. ")",
  }
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
  vim.fn.prompt_setprompt(buf, "")
  log.debug("Prompt set to empty string")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  if opts.callback then
    vim.api.nvim_buf_set_var(buf, "grok_callback", opts.callback)
  end
  local char_count = 0
  local autocmd_id = vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = buf,
    callback = function()
      if not vim.api.nvim_win_is_valid(win) then
        return true
      end
      local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      char_count = #text
      if char_count > max_length then
        vim.notify("Prompt too long! Trimming to max (" .. max_length .. " chars).", vim.log.levels.WARN)
        text = text:sub(1, max_length)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
      end
      vim.api.nvim_win_set_config(win, { title = "Enter Query (" .. char_count .. "/" .. max_length .. ")" })
      local new_height = math.min(8, math.max(3, select(2, text:gsub("\n", "")) + 1))
      if new_height ~= height then
        height = new_height
        win_opts.height = height
        win_opts.row = math.floor(vim.o.lines - height - 2) -- Recalculate bottom row
        vim.api.nvim_win_set_config(win, win_opts)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    callback = function()
      vim.api.nvim_del_autocmd(autocmd_id)
    end,
  })
  vim.api.nvim_buf_set_keymap(
    buf,
    "i",
    "<CR>",
    "<cmd>lua require('grok.util').submit_input()<CR>",
    { noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    buf,
    "i",
    "<Esc>",
    "<cmd>lua vim.api.nvim_win_close(0, true)<CR>",
    { noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    buf,
    "i",
    "<C-u>",
    "<cmd>lua vim.api.nvim_buf_set_lines(0, 0, -1, false, {})<CR>",
    { noremap = true, silent = true }
  )
  vim.api.nvim_command("startinsert")
end

function M.submit_input()
  local buf = vim.api.nvim_get_current_buf()
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local ok, callback = pcall(vim.api.nvim_buf_get_var, buf, "grok_callback")
  vim.api.nvim_win_close(0, true)
  if ok and callback then
    callback(text)
  end
end
function M.submit_input()
  local buf = vim.api.nvim_get_current_buf()
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local ok, callback = pcall(vim.api.nvim_buf_get_var, buf, "grok_callback")
  vim.api.nvim_win_close(0, true)
  if ok and callback then
    callback(text)
  end
end

return M
