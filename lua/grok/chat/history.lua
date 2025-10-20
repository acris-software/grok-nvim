-- ~/github.com/acris-software/grok-nvim/lua/grok/chat/history.lua

local M = {}

M.history = {}

function M.add(role, content)
  table.insert(M.history, { role = role, content = content })
end

function M.get()
  return M.history
end

function M.clear()
  M.history = {}
end

return M
