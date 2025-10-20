-- ~/github.com/acris-software/grok-nvim/lua/grok/chat.lua

local M = {}
local curl = require("plenary.curl")
local async = require("plenary.async")
local ui = require("grok.ui")
local log = require("grok.log")

-- Initialize conversation history
local history = {}

function M.chat(prompt)
  local config = require("grok").config
  if not config.api_key then
    vim.notify("GROK_KEY not set!", vim.log.levels.ERROR)
    log.error("API key not set")
    return
  end
  async.run(function()
    ui.open_chat_window(function(input)
      table.insert(history, { role = "user", content = input })
      local body = vim.json.encode({
        model = config.model,
        messages = history,
        temperature = config.temperature,
        max_tokens = config.max_tokens,
        stream = true,
      })
      log.log("Request body: " .. body)
      local response = ""
      local is_first_chunk = true
      vim.schedule(function()
        local ok, err = pcall(vim.api.nvim_buf_set_lines, ui.current_buf, -2, -1, false, { "Grok: Reasoning..." })
        if not ok then
          log.error("Failed to set reasoning line: " .. vim.inspect(err))
        end
        ok, err = pcall(vim.api.nvim_win_set_cursor, ui.current_win, { vim.api.nvim_buf_line_count(ui.current_buf), 0 })
        if not ok then
          log.error("Failed to set cursor: " .. vim.inspect(err))
        end
        ok, err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", false)
        if not ok then
          log.error("Failed to set modifiable false: " .. vim.inspect(err))
        end
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
              local ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
              if not ok then
                log.error("Failed to set modifiable true for error: " .. vim.inspect(set_err))
              end
              ui.append_response("Error: " .. vim.inspect(err))
              ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
              if not ok then
                log.error("Failed to set modifiable true after error: " .. vim.inspect(set_err))
              end
            end)
            return
          end
          if data then
            log.log("Stream data: " .. data)
            local json_str = data:gsub("^data: ", "")
            if json_str == "[DONE]" then
              vim.schedule(function()
                ui.append_response("\n\n")
                local ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
                if not ok then
                  log.error("Failed to set modifiable true for done: " .. vim.inspect(set_err))
                end
                ok, set_err = pcall(vim.api.nvim_buf_set_lines, ui.current_buf, -1, -1, false, { "" })
                if not ok then
                  log.error("Failed to set lines for done: " .. vim.inspect(set_err))
                end
                ok, set_err =
                  pcall(vim.api.nvim_win_set_cursor, ui.current_win, { vim.api.nvim_buf_line_count(ui.current_buf), 0 })
                if not ok then
                  log.error("Failed to set cursor for done: " .. vim.inspect(set_err))
                end
                ok, set_err = pcall(vim.api.nvim_command, "startinsert")
                if not ok then
                  log.error("Failed to start insert for done: " .. vim.inspect(set_err))
                end
                ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
                if not ok then
                  log.error("Failed to set modifiable true after done: " .. vim.inspect(set_err))
                end
              end)
              table.insert(history, { role = "assistant", content = response })
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
                    local set_ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
                    if not set_ok then
                      log.error("Failed to set modifiable true for first chunk: " .. vim.inspect(set_err))
                    end
                    local line_count = vim.api.nvim_buf_line_count(ui.current_buf)
                    local lines_ok, lines_err = pcall(
                      vim.api.nvim_buf_set_lines,
                      ui.current_buf,
                      line_count - 1,
                      line_count,
                      false,
                      { "Grok: " .. delta_content }
                    )
                    if not lines_ok then
                      log.error("Failed to set lines for first chunk: " .. vim.inspect(lines_err))
                    end
                    local cursor_ok, cursor_err =
                      pcall(vim.api.nvim_win_set_cursor, ui.current_win, { line_count, #("Grok: " .. delta_content) })
                    if not cursor_ok then
                      log.error("Failed to set cursor for first chunk: " .. vim.inspect(cursor_err))
                    end
                    set_ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", false)
                    if not set_ok then
                      log.error("Failed to set modifiable false for first chunk: " .. vim.inspect(set_err))
                    end
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
              local ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
              if not ok then
                log.error("Failed to set modifiable true for non-200: " .. vim.inspect(set_err))
              end
              ui.append_response("Error: " .. res.status .. " - " .. (res.body or "API issue"))
              ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
              if not ok then
                log.error("Failed to set modifiable true after non-200: " .. vim.inspect(set_err))
              end
            end
          end)
        end,
      })
    end)
    if prompt and prompt ~= "" then
      vim.schedule(function()
        local ok, err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
        if not ok then
          log.error("Failed to set modifiable for initial prompt: " .. vim.inspect(err))
        end
        ok, err = pcall(vim.api.nvim_buf_set_lines, ui.current_buf, -2, -1, false, { "", "You: " .. prompt, "" })
        if not ok then
          log.error("Failed to set initial prompt lines: " .. vim.inspect(err))
        end
        ok, err = pcall(vim.api.nvim_win_set_cursor, ui.current_win, { vim.api.nvim_buf_line_count(ui.current_buf), 0 })
        if not ok then
          log.error("Failed to set cursor for initial prompt: " .. vim.inspect(err))
        end
        -- Call callback to send the prompt
        callback(prompt)
      end)
    else
      vim.schedule(function()
        local ok, err =
          pcall(vim.api.nvim_win_set_cursor, ui.current_win, { vim.api.nvim_buf_line_count(ui.current_buf), 0 })
        if not ok then
          log.error("Failed to set cursor: " .. vim.inspect(err))
        end
        ok, err = pcall(vim.api.nvim_command, "startinsert")
        if not ok then
          log.error("Failed to start insert: " .. vim.inspect(err))
        end
      end)
    end
  end)
end

function M.clear_history()
  history = {}
  log.info("Conversation history cleared")
end

return M
