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

-- Theme-aware highlights
local color = require("grok.ui.color")
local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
local float_hl = vim.api.nvim_get_hl(0, { name = "NormalFloat" })

local user_fg = normal_hl.fg and string.format("#%06x", normal_hl.fg) or "#c0caf5" -- Lightish blue-grey fallback
local grok_bg_hex = float_hl.bg and string.format("#%06x", float_hl.bg) or "#1e1e1e" -- Dark fallback
local grok_bg_dark = color.darken_color(grok_bg_hex, 0.8) -- Darken by 20%
local grok_fg = float_hl.fg and string.format("#%06x", float_hl.fg) or "#ffffff"

vim.api.nvim_set_hl(0, "GrokUser", { fg = user_fg }) -- Lighter fg for user
vim.api.nvim_set_hl(0, "GrokAssistant", { bg = grok_bg_dark, fg = grok_fg }) -- Darker bg for Grok

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
