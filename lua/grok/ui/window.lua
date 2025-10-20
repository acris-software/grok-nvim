-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/window.lua

local function open_chat_window(callback)
  local log = require("grok.log")
  log.info("=== WINDOW: open_chat_window START ===")
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
  log.debug("=== WINDOW: Created buf=" .. buf .. ", win=" .. win)

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
  require("grok.ui").current_buf = buf
  require("grok.ui").current_win = win
  log.debug("=== WINDOW: Set current_buf=" .. buf .. ", current_win=" .. win)

  -- Render initial tab
  require("grok.ui.render").render_tab_content(buf, callback)
  -- Set keymaps
  require("grok.ui.keymaps").set_keymaps(buf, win, callback)

  -- v0.1.1: Autocmd for config tab real-time updates
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    callback = function(ev)
      local current_tab = require("grok.ui").current_tab
      if current_tab == 3 then -- Config tab
        log.info("=== WINDOW: Config tab changes applied")
        -- No overwrite of user basics; only UI opts
      end
    end,
  })

  log.info("=== WINDOW: open_chat_window COMPLETE ===")
  return buf, win
end

local function close_chat_window()
  local log = require("grok.log")
  log.info("=== WINDOW: close_chat_window START ===")
  local current_win = require("grok.ui").current_win
  local current_buf = require("grok.ui").current_buf

  if current_win and vim.api.nvim_win_is_valid(current_win) then
    log.debug("=== WINDOW: Closing win " .. current_win)
    pcall(vim.api.nvim_win_close, current_win, true)
  else
    log.debug("=== WINDOW: No valid win to close")
  end

  if current_buf and vim.api.nvim_buf_is_valid(current_buf) then
    log.debug("=== WINDOW: Deleting buf " .. current_buf)
    pcall(vim.api.nvim_buf_delete, current_buf, { force = true })
  else
    log.debug("=== WINDOW: No valid buf to delete")
  end

  require("grok.ui").current_buf = nil
  require("grok.ui").current_win = nil
  log.info("=== WINDOW: close_chat_window COMPLETE ===")
end

return { open_chat_window = open_chat_window, close_chat_window = close_chat_window }
