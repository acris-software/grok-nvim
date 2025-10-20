-- ~/github.com/acris-software/grok-nvim/lua/grok/chat/init.lua

local M = {}
local async = require("plenary.async")
local ui = require("grok.ui")
local log = require("grok.log")
local request = require("grok.chat.request")
local util = require("grok.util")

function M.chat(prompt)
  local config = require("grok").config
  if not config.api_key then
    vim.notify("GROK_KEY not set!", vim.log.levels.ERROR)
    return
  end
  async.run(function()
    ui.open_chat_window(function(input)
      local ok, err = pcall(function()
        local buf = ui.current_buf
        vim.api.nvim_buf_set_option(buf, "modifiable", true)
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "You: " .. input, "" })
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
      end)
      if not ok then
        log.error("Append input failed: " .. vim.inspect(err))
      end
      request.send_request(input)
    end)
    if prompt and prompt ~= "" then
      request.send_request(prompt)
    else
      util.create_floating_input(function(input)
        local ok, err = pcall(function()
          local buf = ui.current_buf
          vim.api.nvim_buf_set_option(buf, "modifiable", true)
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "You: " .. input, "" })
          vim.api.nvim_buf_set_option(buf, "modifiable", false)
        end)
        if not ok then
          log.error("Append input failed: " .. vim.inspect(err))
        end
        request.send_request(input)
      end)
    end
  end)
end

function M.clear_history()
  require("grok.chat.history").clear()
  log.info("Conversation history cleared")
end

return M
