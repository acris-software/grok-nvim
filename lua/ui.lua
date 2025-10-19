local M = {}
local ns = vim.api.nvim_create_namespace("grok_chat")
M.current_buf = nil
M.current_win = nil

function M.open_chat_window(callback)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.6),
    row = math.floor(vim.o.lines * 0.1),
    col = math.floor(vim.o.columns * 0.1),
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    false,
    { "Grok: Ready! Type your query below:", "----------------------------------------", "" }
  )
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(buf, "shiftwidth", 2)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- Auto-enter insert mode at the bottom
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
  vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
  vim.api.nvim_command("startinsert")

  vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local input = lines[#lines] or ""
      if input:match("^%s*$") then
        return
      end -- Ignore empty input
      vim.api.nvim_buf_set_lines(buf, -2, -1, false, { "", "You: " .. input, "" })
      vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      vim.api.nvim_command("startinsert")
      callback(input)
    end,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })

  M.current_buf = buf
  M.current_win = win
  return buf, win
end

function M.append_response(text)
  if
    not M.current_buf
    or not vim.api.nvim_buf_is_valid(M.current_buf)
    or not M.current_win
    or not vim.api.nvim_win_is_valid(M.current_win)
  then
    vim.notify("Grok chat buffer or window closed!", vim.log.levels.WARN)
    return
  end
  local lines = vim.split(text, "\n")
  vim.api.nvim_buf_set_lines(M.current_buf, -2, -1, false, lines)
  vim.api.nvim_win_set_cursor(M.current_win, { vim.api.nvim_buf_line_count(M.current_buf), 0 })
  vim.api.nvim_command("startinsert")
end

return M
