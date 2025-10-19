-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/window.lua

local function open_chat_window(callback)
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
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(buf, "shiftwidth", 2)
  vim.api.nvim_win_set_option(win, "cursorline", true)
  -- Enable syntax highlighting via Treesitter if available
  pcall(require("nvim-treesitter.highlight").attach, buf, "markdown")

  -- Set state before rendering to avoid nil errors
  require("grok.ui").current_buf = buf
  require("grok.ui").current_win = win

  -- Render initial tab
  require("grok.ui.render").render_tab_content(buf, callback)

  -- Set keymaps
  require("grok.ui.keymaps").set_keymaps(buf, win, callback)

  return buf, win
end

local function close_chat_window()
  if require("grok.ui").current_win and vim.api.nvim_win_is_valid(require("grok.ui").current_win) then
    vim.api.nvim_win_close(require("grok.ui").current_win, true)
  end
  require("grok.ui").current_buf = nil
  require("grok.ui").current_win = nil
end

return { open_chat_window = open_chat_window, close_chat_window = close_chat_window }
