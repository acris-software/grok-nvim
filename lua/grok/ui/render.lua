-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/render.lua

local tabs = { "1: Grok", "2: Keymaps", "3: Config" }

local function render_tab_header(buf)
  local header = {}
  for i, tab_name in ipairs(tabs) do
    local prefix = (i == require("grok.ui").current_tab) and "> " or "  "
    table.insert(header, prefix .. tab_name)
  end
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, { table.concat(header, " | ") })
  vim.api.nvim_buf_add_highlight(buf, require("grok.ui").ns, "CursorLine", 0, 0, -1) -- Highlight header
end

local function render_tab_content(buf, callback)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 1, -1, false, {}) -- Clear content below header
  if require("grok.ui").current_tab == 1 then -- Grok
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Grok: Ready! Type your query below:", "" })
    vim.api.nvim_win_set_cursor(require("grok.ui").current_win, { vim.api.nvim_buf_line_count(buf), 0 })
    vim.api.nvim_command("startinsert")
  elseif require("grok.ui").current_tab == 2 then -- Keymaps
    local keymaps = {
      "In Grok Chat Window:",
      "  <CR>   Send query",
      "  <Esc>  Close window",
      "Additional:",
      "  <Left>/<Right> or arrows: Switch tabs",
      "  [1]/[2]/[3]: Jump to tab",
    }
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, keymaps)
  elseif require("grok.ui").current_tab == 3 then -- Config
    local config = require("grok").config
    local config_lines = {
      "Current Configuration:",
      "  Model: " .. config.model,
      "  Temperature: " .. config.temperature,
      "  Max Tokens: " .. config.max_tokens,
      "  Debug: " .. tostring(config.debug),
      -- TODO: Add more
    }
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, config_lines)
  end
  render_tab_header(buf) -- Refresh header with highlight
  vim.api.nvim_buf_set_option(buf, "modifiable", false) -- Lock non-chat tabs
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
  vim.api.nvim_buf_set_option(require("grok.ui").current_buf, "modifiable", false)
end

return {
  render_tab_header = render_tab_header,
  render_tab_content = render_tab_content,
  append_response = append_response,
}
