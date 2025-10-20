-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/state.lua

local M = {}
local state_file = vim.fn.stdpath("data") .. "/grok_ui_state.json"
local log = require("grok.log")

M.state = {
  current_tab = 1, -- Default to Grok tab
}

function M.load()
  local file = io.open(state_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    if content and content ~= "" then
      local ok, loaded_state = pcall(vim.json.decode, content)
      if ok and type(loaded_state) == "table" then
        M.state = loaded_state
        log.debug("Loaded UI state: " .. vim.inspect(M.state))
      end
    end
  end
end

function M.save()
  local file = io.open(state_file, "w")
  if file then
    file:write(vim.json.encode(M.state))
    file:close()
    log.debug("Saved UI state: " .. vim.inspect(M.state))
  end
end

return M
