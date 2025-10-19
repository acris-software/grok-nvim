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
      local is_first_chunk = true
      vim.schedule(function()
        vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", false)
        vim.api.nvim_buf_set_lines(ui.current_buf, -2, -1, false, { "Grok: Reasoning..." })
        vim.api.nvim_win_set_cursor(ui.current_win, { vim.api.nvim_buf_line_count(ui.current_buf), 0 })
      end)
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
              vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", true)
            end)
            return
          end
          if data then
            log.log("Stream data: " .. data)
            local json_str = data:gsub("^data: ", "")
            if json_str == "[DONE]" then
              vim.schedule(function()
                ui.append_response("\n\n")
                vim.api.nvim_buf_set_lines(ui.current_buf, -1, -1, false, { "" })
                vim.api.nvim_win_set_cursor(ui.current_win, { vim.api.nvim_buf_line_count(ui.current_buf), 0 })
                vim.api.nvim_command("startinsert")
                vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", true)
              end)
              return
            end
            local ok, json = pcall(vim.json.decode, json_str)
            if ok and json.choices and json.choices[1].delta then
              local delta_content = json.choices[1].delta.content or json.choices[1].delta.reasoning_content or ""
              if delta_content ~= "" then
                response = response .. delta_content
                vim.schedule(function()
                  if is_first_chunk then
                    is_first_chunk = false
                    local line_count = vim.api.nvim_buf_line_count(ui.current_buf)
                    vim.api.nvim_buf_set_lines(
                      ui.current_buf,
                      line_count - 1,
                      line_count,
                      false,
                      { "Grok: " .. delta_content }
                    )
                    vim.api.nvim_win_set_cursor(ui.current_win, { line_count, #("Grok: " .. delta_content) })
                  else
                    ui.append_response(delta_content)
                  end
                end)
              end
            end
          end
        end,
        callback = function(res)
          vim.schedule(function()
            log.log("Response status: " .. res.status)
            if res.status ~= 200 then
              ui.append_response("Error: " .. res.status .. " - " .. (res.body or "API issue"))
              vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", true)
            end
          end)
        end,
      })
    end)
  end)
end
return M
