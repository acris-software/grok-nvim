-- ~/github.com/acris-software/grok-nvim/lua/grok/ui.lua

local M = {}
local ns = vim.api.nvim_create_namespace("grok_chat")
M.current_buf = nil
M.current_win = nil
M.current_tab = 1

M.open_chat_window = require("grok.ui.window").open_chat_window
M.append_response = require("grok.ui.render").append_response
M.close_chat_window = require("grok.ui.window").close_chat_window

return M
