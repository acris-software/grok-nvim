-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/render.lua

local function render_tab_header(buf)
  local header = {}
  for i, tab_name in ipairs(require("grok.ui").tabs) do
    local prefix = (i == require("grok.ui").current_tab) and "> " or " "
    table.insert(header, prefix .. tab_name)
  end
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { table.concat(header, " | ") })
  vim.api.nvim_buf_add_highlight(buf, require("grok.ui").ns, "CursorLine", 0, 0, -1) -- Highlight header
end

local function render_tab_content(buf, callback)
  local history = require("grok.chat").history -- For re-rendering (Issue 1)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 1, -1, false, {})
  vim.cmd("stopinsert")
  if require("grok.ui").current_tab == 1 then -- Grok/Chat
    local chat_lines = {}
    for _, msg in ipairs(history) do
      local role = msg.role == "user" and "You" or "Grok"
      local content_lines = vim.split(msg.content, "\n", { plain = true })
      table.insert(chat_lines, role .. ": " .. (content_lines[1] or ""))
      for i = 2, #content_lines do
        table.insert(chat_lines, "  " .. content_lines[i])
      end
      table.insert(chat_lines, "")
    end
    if #history == 0 then
      table.insert(chat_lines, "Grok: Ready! Type your query below:")
      table.insert(chat_lines, "")
    end
    table.insert(chat_lines, "") -- Input line
    vim.api.nvim_buf_set_lines(buf, 1, -1, false, chat_lines)
    local line_count = vim.api.nvim_buf_line_count(buf)
    require("grok.ui").protected_end = line_count - 1 -- Update protected (Issue 3)
    if require("grok.ui").current_win and vim.api.nvim_win_is_valid(require("grok.ui").current_win) then
      vim.api.nvim_win_set_cursor(require("grok.ui").current_win, { line_count, 0 })
      vim.api.nvim_command("startinsert")
    end
    render_tab_header(buf) -- Refresh header
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
  else
    local content_lines = {}
    if require("grok.ui").current_tab == 2 then -- Keymaps
      content_lines = {
        "In Grok Chat Window:",
        " <CR> Send query (in insert mode)",
        " <Esc> Close window (in normal mode)",
        "Additional:",
        " <Tab> / <S-Tab>: Switch tabs forward/back (in normal or visual mode)",
        " [1]/[2]/[3]: Jump to tab (in normal or visual mode)",
        " i: Enter insert mode (in Grok tab only, from normal/visual)",
        "Tip: Press <Esc> to enter normal mode for navigation; 'i' to insert for typing in Grok tab.",
      }
    elseif require("grok.ui").current_tab == 3 then -- Config
      local config = require("grok").config
      content_lines = {
        "Current Configuration:",
        " Model: " .. config.model,
        " Temperature: " .. config.temperature,
        " Max Tokens: " .. config.max_tokens,
        " Debug: " .. tostring(config.debug),
        -- TODO: Add more
      }
    end
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, content_lines)
    render_tab_header(buf) -- Refresh header before locking
    vim.api.nvim_buf_set_option(buf, "modifiable", false) -- Lock non-chat tabs
  end
end

local function append_response(text)
  if
    not require("grok.ui").current_buf
    or not vim.api.nvim_buf_is_valid(require("grok.ui").current_buf)
    or not require("grok.ui").current_win
    or not vim.api.nvim_win_is_valid(require("grok.ui").current_win)
    or require("grok.ui").current_tab ~= 1
  then
    vim.notify("Grok chat buffer or window closed or not in Grok tab!", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_buf_set_option(require("grok.ui").current_buf, "modifiable", true)
  local line_count = vim.api.nvim_buf_line_count(require("grok.ui").current_buf)
  local last_line = vim.api.nvim_buf_get_lines(require("grok.ui").current_buf, line_count - 1, line_count, false)[1]
    or ""
  local new_text = last_line .. text
  local lines = vim.split(new_text, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(require("grok.ui").current_buf, line_count - 1, line_count, false, lines)
  vim.api.nvim_win_set_cursor(
    require("grok.ui").current_win,
    { vim.api.nvim_buf_line_count(require("grok.ui").current_buf), 0 }
  )
  require("grok.ui").protected_end = vim.api.nvim_buf_line_count(require("grok.ui").current_buf) - 1 -- Update protected (Issue 3)
  vim.api.nvim_buf_set_option(require("grok.ui").current_buf, "modifiable", false) -- Lock after append for consistency
end

return {
  render_tab_header = render_tab_header,
  render_tab_content = render_tab_content,
  append_response = append_response,
}
