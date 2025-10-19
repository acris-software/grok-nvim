-- ~/github.com/acris-software/grok-nvim/lua/grok/log.lua

local M = {}
M.log = require("grok.log.core").log
M.debug = require("grok.log.core").debug
M.info = require("grok.log.core").info
M.error = require("grok.log.core").error

return M
