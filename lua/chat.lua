local M = {}
local curl = require("plenary.curl")
local async = require("plenary.async")
local ui = require("grok.ui")

function M.chat(prompt)
  local config = require("grok").config -- Access config from init

  if not config.api_key then
    vim.notify("GROK_API_KEY not set!", vim.log.levels.ERROR)
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
      vim.notify("Request body: " .. body, vim.log.levels.DEBUG) -- Log request body
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
            vim.notify("Stream data: " .. data, vim.log.levels.DEBUG) -- Log stream data
            local ok, json = pcall(vim.json.decode, data)
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
            vim.notify("Response status: " .. res.status, vim.log.levels.DEBUG) -- Log response status
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
