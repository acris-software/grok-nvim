-- ~/github.com/acris-software/grok-nvim/lua/grok/log.lua

local M = {}
local log_file = vim.fn.stdpath("data") .. "/grok.log"
local max_log_size = 1024 * 1024 -- 1MB
local last_message = nil
local repeat_count = 0

local function rotate_log()
  local file_info = vim.uv.fs_stat(log_file)
  if file_info and file_info.size > max_log_size then
    local old_log = log_file .. ".old"
    os.remove(old_log)
    os.rename(log_file, old_log)
  end
end

function M.log(message, is_error)
  if require("grok").config.debug then
    rotate_log()
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local prefix = is_error and "[ERROR] " or ""
    local full_message = timestamp .. " " .. prefix .. message
    if full_message == last_message then
      repeat_count = repeat_count + 1
      return -- Throttle
    else
      if repeat_count > 0 then
        local repeat_note = timestamp .. " [REPEAT] Previous message repeated " .. repeat_count .. " times"
        local file = io.open(log_file, "a")
        if file then
          file:write(repeat_note .. "\n")
          file:close()
        end
      end
      repeat_count = 0
      last_message = full_message
      local file = io.open(log_file, "a")
      if file then
        file:write(full_message .. "\n")
        file:close()
      end
    end
  end
end

function M.error(message, request_context)
  local context = request_context and ("Request: " .. request_context .. " | Error: ") or ""
  M.log(context .. message, true)
end

return M
