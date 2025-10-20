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
    log.error("API key not set")
    return
  end
  log.debug("=== CHAT INIT: Starting chat session ===")
  async.run(function()
    ui.open_chat_window(function(input)
      log.debug("=== CHAT INIT: Callback received input: " .. (input or "nil"))
      local ok, err = pcall(function()
        vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", true)
        vim.api.nvim_buf_set_lines(ui.current_buf, -1, -1, false, { "", "You: " .. input, "" })
        vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", false)
      end)
      if not ok then
        log.error("Failed to append user input: " .. vim.inspect(err))
      end
      request.send_request(input)
    end)
    if prompt and prompt ~= "" then
      log.debug("=== CHAT INIT: Using provided prompt: " .. prompt)
      vim.schedule(function()
        local ok, err = pcall(function()
          vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", true)
          vim.api.nvim_buf_set_lines(ui.current_buf, -1, -1, false, { "", "You: " .. prompt, "" })
          vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", false)
        end)
        if not ok then
          log.error("Failed to append initial prompt: " .. vim.inspect(err))
        end
        request.send_request(prompt)
      end)
    else
      log.debug("=== CHAT INIT: No prompt, opening floating input ===")

      util.create_floating_input({
        on_submit = function(input)
          log.debug("=== CHAT INIT: Floating input submitted: " .. input)

          local ok, err = pcall(function()
            vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", true)
            vim.api.nvim_buf_set_lines(ui.current_buf, -1, -1, false, { "", "You: " .. input, "" })
            vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", false)
          end)
          if not ok then
            log.error("Failed to append user input: " .. vim.inspect(err))
          end
          request.send_request(input)
        end,
      })
    end
  end)
end

function M.clear_history()
  require("grok.chat.history").clear()
  log.info("Conversation history cleared")
end

return M
