-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/window.lua

local function open_chat_window(callback)
  local log = require("grok.log")
  local ui = require("grok.ui")

  -- Return existing window if valid
  if
    ui.current_win
    and vim.api.nvim_win_is_valid(ui.current_win)
    and ui.current_buf
    and vim.api.nvim_buf_is_valid(ui.current_buf)
  then
    vim.api.nvim_set_current_win(ui.current_win)
    require("grok.ui.render").render_tab_content(ui.current_buf, callback)
    log.debug("Reusing existing chat window: " .. ui.current_win)
    return ui.current_buf, ui.current_win
  end

  log.info("Opening new chat window")
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
  local ok, err = pcall(vim.api.nvim_buf_set_option, buf, "filetype", "markdown")
  if not ok then
    log.error("Failed to set filetype: " .. vim.inspect(err))
  end
  ok, err = pcall(vim.api.nvim_buf_set_option, buf, "shiftwidth", 2)
  if not ok then
    log.error("Failed to set shiftwidth: " .. vim.inspect(err))
  end
  ok, err = pcall(vim.api.nvim_win_set_option, win, "cursorline", true)
  if not ok then
    log.error("Failed to set cursorline: " .. vim.inspect(err))
  end
  pcall(require("nvim-treesitter.highlight").attach, buf, "markdown")
  -- Set state
  ui.current_buf = buf
  ui.current_win = win
  ui.current_callback = callback
  require("grok.ui.render").render_tab_content(buf, callback)
  require("grok.ui.keymaps").set_keymaps(buf, win, callback)
  -- Autocmd for config tab real-time updates
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    callback = function()
      if ui.current_tab == 3 then
        log.info("Config tab changes applied")
      end
    end,
  })
  -- Clean up state on window close
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    callback = function()
      ui.current_buf = nil
      ui.current_win = nil
      ui.current_callback = nil
      log.debug("Chat window closed, cleared UI state")
    end,
  })
  return buf, win
end

local function close_chat_window()
  local log = require("grok.log")
  local ui = require("grok.ui")
  log.info("Closing chat window")
  if ui.current_win and vim.api.nvim_win_is_valid(ui.current_win) then
    vim.api.nvim_win_close(ui.current_win, true)
  end
  ui.current_buf = nil
  ui.current_win = nil
  ui.current_callback = nil
end

return { open_chat_window = open_chat_window, close_chat_window = close_chat_window }
