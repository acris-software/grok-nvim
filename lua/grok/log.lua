-- ~/github.com/acris-software/grok-nvim/lua/grok/log.lua

local M = {}

local log_file = vim.fn.stdpath("data") .. "/grok.log"
local max_log_size = 1024 * 1024 -- 1MB

local function rotate_log()
  local file_info = vim.uv.fs_stat(log_file)
  if file_info and file_info.size > max_log_size then
    local old_log = log_file .. ".old"
    os.remove(old_log)
    os.rename(log_file, old_log)
  end
end

function M.log(message)
  if require("grok").config.debug then
    rotate_log()
    local file = io.open(log_file, "a")
    if file then
      file:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. message .. "\n")
      file:close()
    end
  end
end

return M
