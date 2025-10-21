-- ~/github.com/acris-software/grok-nvim/lua/grok/log/core.lua

local log_file = vim.fn.stdpath("data") .. "/grok.log"
local max_log_size = 1024 * 1024 -- 1MB
local last_message = nil
local repeat_count = 0
local message_cache = {} -- Cache for throttling: {message = timestamp}
local throttle_interval = 5000

local function rotate_log()
  local file_info = vim.uv.fs_stat(log_file)
  if file_info and file_info.size > max_log_size then
    local old_log = log_file .. ".old"
    os.remove(old_log)
    os.rename(log_file, old_log)
  end
end

local function write_log(full_message)
  rotate_log()
  local file = io.open(log_file, "a")
  if file then
    file:write(full_message .. "\n")
    file:close()
  end
end

local function log(message, level)
  if not require("grok").config.debug then
    return
  end
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local prefix = level or ""
  local full_message = timestamp .. " " .. prefix .. message
  local now = vim.loop.now()

  -- Check if message was logged recently
  local last_logged = message_cache[message]
  if last_logged and (now - last_logged) < throttle_interval then
    return -- Throttle: skip if logged within throttle_interval
  end

  -- Update cache with current timestamp
  message_cache[message] = now

  -- Handle repeated messages
  if full_message == last_message then
    repeat_count = repeat_count + 1
    return -- Throttle consecutive identical messages
  else
    if repeat_count > 0 then
      local repeat_note = timestamp .. " [REPEAT] Previous message repeated " .. repeat_count .. " times"
      write_log(repeat_note)
    end
    repeat_count = 0
    last_message = full_message
    write_log(full_message)
  end

  -- Clean up old cache entries
  for msg, ts in pairs(message_cache) do
    if (now - ts) >= throttle_interval then
      message_cache[msg] = nil
    end
  end
end

local function debug(message)
  log(message, "[DEBUG] ")
end

local function info(message)
  log(message, "[INFO] ")
end

local function error(message, request_context)
  local context = request_context and ("Request: " .. request_context .. " | ") or ""
  log(context .. message, "[ERROR] ")
end

return { log = log, debug = debug, info = info, error = error }
