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

-- v0.1.1: util Expansion (DEBUG TOGGLE + THROTTLE)
local function debug_log(msg)
  if require("grok").config.debug then
    log.debug(msg)
  end
end

-- THROTTLE
local last_log_time = 0
local last_msg = ""
local function throttled_debug(msg)
  local now = vim.loop.now() / 1000
  if now - last_log_time < 1 or msg == last_msg then
    return
  end
  last_log_time = now
  last_msg = msg
  debug_log(msg)
end

function M.get_model_max_tokens(model)
  local max_tokens = {
    ["grok-3-mini"] = 131072,
  }
  local result = max_tokens[model] or 131072
  throttled_debug("=== UTIL: get_model_max_tokens(" .. model .. ") = " .. result)
  return result
end

function M.validate_config(opts)
  throttled_debug("=== UTIL: Validating config")
  if
    type(opts.prompt_position) ~= "string" or not vim.tbl_contains({ "left", "center", "right" }, opts.prompt_position)
  then
    vim.notify(
      "Invalid prompt_position: must be 'left', 'center', or 'right'. Defaulting to 'center'.",
      vim.log.levels.WARN
    )
    opts.prompt_position = "center"
    throttled_debug("WARN: Invalid prompt_position, defaulted to center")
  end
end

function M.auto_scroll(buf, win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_cursor(win, { line_count, 0 })
  throttled_debug("=== UTIL: Auto-scrolled to line " .. line_count)
end

function M.create_floating_input(opts)
  throttled_debug("=== UTIL: create_floating_input START ===")
  local config = require("grok").config
  local max_length = M.get_model_max_tokens(config.model)
  throttled_debug("=== UTIL: Max length = " .. max_length .. ", position = " .. config.prompt_position)

  local buf = vim.api.nvim_create_buf(false, true)
  throttled_debug("=== UTIL: Created input buf " .. buf)

  local width = math.floor(vim.o.columns * 0.6)
  local height = 3
  local row, col
  if config.prompt_position == "center" then
    row = math.floor((vim.o.lines - height) / 2)
    col = math.floor((vim.o.columns - width) / 2)
  elseif config.prompt_position == "left" then
    row = math.floor(vim.o.lines * 0.1)
    col = math.floor(vim.o.columns * 0.1)
  else
    row = math.floor(vim.o.lines * 0.1)
    col = math.floor(vim.o.columns * 0.3)
  end
  throttled_debug("=== UTIL: Position row=" .. row .. ", col=" .. col)

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
  throttled_debug("=== UTIL: Opened input win " .. win)

  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
  vim.cmd("startinsert")

  -- THROTTLED
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = buf,
    callback = function()
      local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      local char_count = #text
      if char_count > max_length then
        vim.notify("Prompt too long! Trimming to max (" .. max_length .. " chars).", vim.log.levels.WARN)
        text = text:sub(1, max_length)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
        char_count = max_length
      end
      vim.api.nvim_win_set_config(win, { title = "Enter Query (" .. char_count .. "/" .. max_length .. ")" })

      local new_height = math.min(8, math.max(3, select(2, text:gsub("\n", "")) + 1))
      if new_height ~= height then
        height = new_height
        win_opts.height = height
        win_opts.row = math.floor((vim.o.lines - height) / 2)
        vim.api.nvim_win_set_config(win, win_opts)
        throttled_debug("=== UTIL: Auto-grew height to " .. height)
      end
    end,
  })

  -- Keymaps
  vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
    callback = function()
      throttled_debug("=== UTIL: CR pressed in input - SUBMITTING")
      local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      vim.api.nvim_win_close(win, true)
      throttled_debug("=== UTIL: Input submitted (" .. #text .. " chars)")
      require("grok.chat").handle_input(text)
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(buf, "i", "<Esc>", "", {
    callback = function()
      throttled_debug("=== UTIL: ESC pressed - CLOSING")
      vim.api.nvim_win_close(win, true)
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(buf, "i", "<C-u>", "<cmd>%d _<CR>", { noremap = true, silent = true })

  throttled_debug("=== UTIL: create_floating_input COMPLETE ===")
  return buf, win
end

function M.submit_input()
  local buf = vim.api.nvim_get_current_buf()
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  vim.api.nvim_win_close(0, true)
  throttled_debug("=== UTIL: submit_input called (" .. #text .. " chars)")
  require("grok.chat").handle_input(text)
end

return M
