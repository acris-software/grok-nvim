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
  local history = require("grok.chat.history").get() -- For re-rendering
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.cmd("stopinsert")

  -- Apply chat window background
  vim.api.nvim_set_option_value("winhl", "Normal:GrokChatWindow", { win = require("grok.ui").current_win })

  if require("grok.ui").current_tab == 1 then -- Grok
    local chat_lines = {}
    local line_idx = 1 -- Track buffer line for highlighting
    for _, msg in ipairs(history) do
      local role = msg.role == "user" and "You" or "Grok"
      local content_lines = vim.split(msg.content, "\n", { plain = true })
      table.insert(chat_lines, role .. ": " .. (content_lines[1] or ""))
      for i = 2, #content_lines do
        table.insert(chat_lines, "  " .. content_lines[i]) -- Indent continuation lines
      end
      table.insert(chat_lines, "")
    end
    if #history == 0 then
      table.insert(chat_lines, "Grok: Ready! Press <CR> or i to enter query.")
      table.insert(chat_lines, "")
    end
    vim.api.nvim_buf_set_lines(buf, 1, -1, false, chat_lines)

    -- Apply highlights per message block
    local current_line = 1
    for _, msg in ipairs(history) do
      local role = msg.role
      local msg_lines = #vim.split(msg.content, "\n", { plain = true }) + 1 -- +1 for empty line
      local hl_group = (role == "user") and "GrokUser" or "GrokAssistant"
      for i = 0, msg_lines - 1 do
        vim.api.nvim_buf_add_highlight(buf, require("grok.ui").ns, hl_group, current_line + i - 1, 0, -1)
      end
      current_line = current_line + msg_lines
    end

    if require("grok.ui").current_win and vim.api.nvim_win_is_valid(require("grok.ui").current_win) then
      require("grok.util").auto_scroll(buf, require("grok.ui").current_win) -- v0.1.1 Auto-scroll
    end
    render_tab_header(buf) -- Refresh header
    -- Apply header highlight
    vim.api.nvim_buf_add_highlight(buf, require("grok.ui").ns, "GrokHeader", 0, 0, -1)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  else
    local content_lines = {}
    if require("grok.ui").current_tab == 2 then -- Keymaps
      content_lines = {
        "In Grok Chat Window:",
        " <CR> or i: Open input prompt to send query (in normal mode)",
        " <Esc>: Close window (in normal mode)",
        "Additional:",
        " <Tab> / <S-Tab>: Switch tabs forward/back (in normal or visual mode)",
        " [1]/[2]/[3]: Jump to tab (in normal or visual mode)",
        "Tip: Press <Esc> to enter normal mode for navigation.",
      }
    elseif require("grok.ui").current_tab == 3 then -- Config
      local config = require("grok").config
      content_lines = {
        "Current Configuration:",
        " Model: " .. config.model,
        " Temperature: " .. config.temperature,
        " Max Tokens: " .. config.max_tokens,
        " Debug: " .. tostring(config.debug),
        " Prompt Position: " .. config.prompt_position, -- v0.1.1 Visible UI option
      }
    end
    vim.api.nvim_buf_set_lines(buf, 1, -1, false, content_lines)
    render_tab_header(buf) -- Refresh header
    vim.api.nvim_buf_add_highlight(buf, require("grok.ui").ns, "GrokHeader", 0, 0, -1)
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
  local ok, err = pcall(function()
    vim.api.nvim_buf_set_option(require("grok.ui").current_buf, "modifiable", true)
    local line_count = vim.api.nvim_buf_line_count(require("grok.ui").current_buf)
    local last_line = vim.api.nvim_buf_get_lines(require("grok.ui").current_buf, line_count - 1, line_count, false)[1]
      or ""
    local new_text = last_line .. text
    local lines = vim.split(new_text, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(require("grok.ui").current_buf, line_count - 1, line_count, false, lines)
    require("grok.util").auto_scroll(require("grok.ui").current_buf, require("grok.ui").current_win) -- v0.1.1 Auto-scroll
    vim.api.nvim_buf_add_highlight(
      require("grok.ui").current_buf,
      require("grok.ui").ns,
      "GrokAssistant",
      line_count - 1,
      0,
      -1
    )
    vim.api.nvim_buf_set_option(require("grok.ui").current_buf, "modifiable", false)
  end)
  if not ok then
    log.error("Failed to append response: " .. vim.inspect(err))
    vim.notify("Error appending response!", vim.log.levels.ERROR)
  end
end

return {
  render_tab_header = render_tab_header,
  render_tab_content = render_tab_content,
  append_response = append_response,
}
