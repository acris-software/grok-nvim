-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/render.lua

local function render_tab_header(buf)
  local log = require("grok.log")
  log.debug("Rendering tab header")
  local header = {}
  for i, tab_name in ipairs(require("grok.ui").tabs) do
    local prefix = (i == require("grok.ui").current_tab) and "> " or "  "
    table.insert(header, prefix .. tab_name)
  end
  local ok, err = pcall(vim.api.nvim_buf_set_lines, buf, 0, 1, false, { table.concat(header, " | ") })
  if not ok then
    log.error("Failed to set header lines: " .. vim.inspect(err))
  end
  ok, err = pcall(vim.api.nvim_buf_add_highlight, buf, require("grok.ui").ns, "CursorLine", 0, 0, -1)
  if not ok then
    log.error("Failed to add header highlight: " .. vim.inspect(err))
  end
end

local function render_tab_content(buf, callback)
  local log = require("grok.log")
  log.info("Rendering tab content for tab " .. require("grok.ui").current_tab)
  local ok, err = pcall(vim.api.nvim_buf_set_option, buf, "modifiable", true)
  if not ok then
    log.error("Failed to set modifiable true: " .. vim.inspect(err))
  end
  ok, err = pcall(vim.api.nvim_buf_set_lines, buf, 1, -1, false, {})
  if not ok then
    log.error("Failed to clear content: " .. vim.inspect(err))
  end
  vim.cmd("stopinsert") -- Ensure normal mode
  if require("grok.ui").current_tab == 1 then -- Grok/Chat
    ok, err = pcall(vim.api.nvim_buf_set_lines, buf, -1, -1, false, { "Grok: Ready! Type your query below:", "" })
    if not ok then
      log.error("Failed to set ready line: " .. vim.inspect(err))
    end
    if require("grok.ui").current_win and vim.api.nvim_win_is_valid(require("grok.ui").current_win) then
      ok, err =
        pcall(vim.api.nvim_win_set_cursor, require("grok.ui").current_win, { vim.api.nvim_buf_line_count(buf), 0 })
      if not ok then
        log.error("Failed to set cursor: " .. vim.inspect(err))
      end
      ok, err = pcall(vim.api.nvim_command, "startinsert")
      if not ok then
        log.error("Failed to start insert: " .. vim.inspect(err))
      end
    end
    ok, err = pcall(vim.api.nvim_buf_set_option, buf, "modifiable", true) -- Keep modifiable for typing
    if not ok then
      log.error("Failed to set modifiable true for Grok tab: " .. vim.inspect(err))
    end
  elseif require("grok.ui").current_tab == 2 then -- Keymaps
    local keymaps = {
      "In Grok Chat Window:",
      "  <CR>   Send query (in insert mode)",
      "  <Esc>  Close window (in normal mode)",
      "Additional:",
      "  <Tab> / <S-Tab>: Switch tabs forward/back (in normal or visual mode)",
      "  [1]/[2]/[3]: Jump to tab (in normal or visual mode)",
      "  i: Enter insert mode (in Grok tab only, from normal/visual)",
      "Tip: Press <Esc> to enter normal mode for navigation; 'i' to insert for typing in Grok tab.",
    }
    ok, err = pcall(vim.api.nvim_buf_set_lines, buf, -1, -1, false, keymaps)
    if not ok then
      log.error("Failed to set keymaps lines: " .. vim.inspect(err))
    end
    ok, err = pcall(vim.api.nvim_buf_set_option, buf, "modifiable", false)
    if not ok then
      log.error("Failed to set modifiable false for Keymaps tab: " .. vim.inspect(err))
    end
  elseif require("grok.ui").current_tab == 3 then -- Config
    local config = require("grok").config
    local config_lines = {
      "Current Configuration:",
      "  Model: " .. config.model,
      "  Temperature: " .. config.temperature,
      "  Max Tokens: " .. config.max_tokens,
      "  Debug: " .. tostring(config.debug),
      -- Add more as config expands
    }
    ok, err = pcall(vim.api.nvim_buf_set_lines, buf, -1, -1, false, config_lines)
    if not ok then
      log.error("Failed to set config lines: " .. vim.inspect(err))
    end
    ok, err = pcall(vim.api.nvim_buf_set_option, buf, "modifiable", false)
    if not ok then
      log.error("Failed to set modifiable false for Config tab: " .. vim.inspect(err))
    end
  end
  render_tab_header(buf) -- Refresh header
end

local function append_response(text)
  local log = require("grok.log")
  log.debug("Appending response: " .. text)
  if
    not require("grok.ui").current_buf
    or not vim.api.nvim_buf_is_valid(require("grok.ui").current_buf)
    or not require("grok.ui").current_win
    or not vim.api.nvim_win_is_valid(require("grok.ui").current_win)
    or require("grok.ui").current_tab ~= 1
  then
    log.error("Invalid state for append_response")
    vim.notify("Grok chat buffer or window closed or not in Grok tab!", vim.log.levels.WARN)
    return
  end
  local ok, err = pcall(vim.api.nvim_buf_set_option, require("grok.ui").current_buf, "modifiable", true)
  if not ok then
    log.error("Failed to set modifiable true for append: " .. vim.inspect(err))
  end
  local line_count = vim.api.nvim_buf_line_count(require("grok.ui").current_buf)
  local last_line = vim.api.nvim_buf_get_lines(require("grok.ui").current_buf, line_count - 1, line_count, false)[1]
    or ""
  local new_text = last_line .. text
  local lines = vim.split(new_text, "\n", { plain = true })
  ok, err = pcall(vim.api.nvim_buf_set_lines, require("grok.ui").current_buf, line_count - 1, line_count, false, lines)
  if not ok then
    log.error("Failed to append lines: " .. vim.inspect(err))
  end
  ok, err = pcall(
    vim.api.nvim_win_set_cursor,
    require("grok.ui").current_win,
    { vim.api.nvim_buf_line_count(require("grok.ui").current_buf), 0 }
  )
  if not ok then
    log.error("Failed to set cursor for append: " .. vim.inspect(err))
  end
  ok, err = pcall(vim.api.nvim_buf_set_option, require("grok.ui").current_buf, "modifiable", true) -- Keep modifiable
  if not ok then
    log.error("Failed to set modifiable true after append: " .. vim.inspect(err))
  end
end

return {
  render_tab_header = render_tab_header,
  render_tab_content = render_tab_content,
  append_response = append_response,
}
