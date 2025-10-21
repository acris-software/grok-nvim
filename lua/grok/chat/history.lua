-- ~/github.com/acris-software/grok-nvim/lua/grok/chat/history.lua
local M = {}

local history_file = vim.fn.stdpath("data") .. "/grok_chat_history.json"
M.history = {}

function M.load()
  local file = io.open(history_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    if content and content ~= "" then
      local ok, loaded_history = pcall(vim.json.decode, content)
      if ok and type(loaded_history) == "table" then
        M.history = loaded_history
      end
    end
  end
end

function M.save()
  local file = io.open(history_file, "w")
  if file then
    file:write(vim.json.encode(M.history))
    file:close()
  end
end

function M.add(role, content)
  table.insert(M.history, { role = role, content = content })
  -- Limit history to 10 messages to prevent excessive growth
  if #M.history > 10 then
    table.remove(M.history, 1)
  end
  M.save()
end

function M.get()
  if #M.history == 0 then
    M.load()
  end
  return M.history
end

function M.clear()
  M.history = {}
  M.save()
end

return M
