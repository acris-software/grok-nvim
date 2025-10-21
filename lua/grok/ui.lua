-- ~/github.com/acris-software/grok-nvim/lua/grok/ui.lua

local M = {}
local log = require("grok.log")

M.ns = vim.api.nvim_create_namespace("grok_chat")
M.current_buf = nil
M.current_win = nil
M.current_tab = 1
M.current_callback = nil
M.tabs = { "1: Grok", "2: Keymaps", "3: Config" }

-- Load persistent state
local ui_state = require("grok.ui.state")
M.current_tab = ui_state.state.current_tab

-- Fixed highlights for v0.1.1 polish (Grok UI-inspired)
vim.api.nvim_set_hl(0, "GrokChatWindow", { bg = "#000000" }) -- Solid black for entire chat
vim.api.nvim_set_hl(0, "GrokAssistant", { bg = "#000000", fg = "#ffffff" }) -- Black bg, white fg for Grok
vim.api.nvim_set_hl(0, "GrokUser", { bg = "#333333", fg = "#ffffff" }) -- Charcoal gray bg, white fg for user
vim.api.nvim_set_hl(0, "GrokHeader", { bg = "#666666", fg = "#ffffff" }) -- Lighter gray for header

M.open_chat_window = require("grok.ui.window").open_chat_window
M.append_response = require("grok.ui.render").append_response
M.close_chat_window = require("grok.ui.window").close_chat_window

-- Update current_tab and save state
function M.set_current_tab(tab_idx)
  M.current_tab = tab_idx
  ui_state.state.current_tab = tab_idx
  ui_state.save()
  log.debug("Set current tab to " .. tab_idx)
end

-- Command to toggle or show UI
function M.toggle_ui()
  if M.current_win and vim.api.nvim_win_is_valid(M.current_win) then
    M.close_chat_window()
  else
    M.open_chat_window(function(input)
      require("grok.chat").chat(input)
    end)
  end
end

return M
