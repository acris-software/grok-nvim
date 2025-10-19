-- ~/github.com/acris-software/grok-nvim/lua/grok/chat.lua

local M = {}
local curl = require("plenary.curl")
local async = require("plenary.async")
local ui = require("grok.ui")
local log = require("grok.log")

function M.chat(prompt)
  local config = require("grok").config
  if not config.api_key then
    vim.notify("GROK_KEY not set!", vim.log.levels.ERROR)
    return
  end
  async.run(function()
    ui.open_chat_window(function(input)
      local body = vim.json.encode({
        model = config.model,
        messages = { { role = "user", content = prompt .. "\n\n" .. input } },
        temperature = config.temperature,
        max_tokens = config.max_tokens,
        stream = true,
      })
      log.log("Request body: " .. body)
      local response = ""
      curl.post(config.base_url .. "/chat/completions", {
        headers = {
          authorization = "Bearer " .. config.api_key,
          ["content-type"] = "application/json",
        },
        body = body,
        stream = function(err, data, _)
          if err then
            vim.schedule(function()
              ui.append_response("Error: " .. vim.inspect(err))
            end)
            return
          end
          if data then
            log.log("Stream data: " .. data)
            local json_str = data:gsub("^data: ", "")
            if json_str == "[DONE]" then
              return
            end
            local ok, json = pcall(vim.json.decode, json_str)
            if ok and json.choices and json.choices[1].delta and json.choices[1].delta.content then
              response = response .. json.choices[1].delta.content
              vim.schedule(function()
                ui.append_response(json.choices[1].delta.content)
              end)
            end
          end
        end,
        callback = function(res)
          vim.schedule(function()
            log.log("Response status: " .. res.status)
            if res.status ~= 200 then
              ui.append_response("Error: " .. res.status .. " - " .. (res.body or "API issue"))
            end
          end)
        end,
      })
    end)
  end)
end

return M
