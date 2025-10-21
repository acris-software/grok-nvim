-- ~/github.com/acris-software/grok-nvim/lua/grok/chat/request.lua

local curl = require("plenary.curl")
local log = require("grok.log")
local ui = require("grok.ui")
local history = require("grok.chat.history")

local function send_request(input)
  local config = require("grok").config
  history.add("user", input)
  local body = vim.json.encode({
    model = config.model,
    messages = history.get(),
    temperature = config.temperature,
    max_tokens = config.max_tokens,
    stream = true,
  })
  log.log("Request body: " .. body)
  local response = ""
  local is_first_chunk = true
  vim.schedule(function()
    local ok, err = pcall(function()
      vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", true)
      vim.api.nvim_buf_set_lines(ui.current_buf, -1, -1, false, { "Grok: Reasoning..." })
      vim.api.nvim_buf_set_option(ui.current_buf, "modifiable", false)
      vim.api.nvim_win_set_cursor(ui.current_win, { vim.api.nvim_buf_line_count(ui.current_buf), 0 })
    end)
    if not ok then
      log.error("Failed to set reasoning line: " .. vim.inspect(err))
      vim.notify("UI Error: Failed to update reasoning!", vim.log.levels.ERROR)
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
          ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", false)
          if not ok then
            log.error("Failed to set modifiable false after error: " .. vim.inspect(set_err))
          end
          vim.notify("API Error: Request failed!", vim.log.levels.ERROR)
        end)
        return
      end
      if data then
        log.log("Stream data: " .. data)
        local json_str = data:gsub("^data: ", "")
        if json_str == "[DONE]" then
          vim.schedule(function()
            local ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
            if not ok then
              log.error("Failed to set modifiable true for done: " .. vim.inspect(set_err))
            end
            -- Ensure final response is appended
            ui.append_response("\n\n")
            ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", false)
            if not ok then
              log.error("Failed to set modifiable false after done: " .. vim.inspect(set_err))
            end
            history.add("assistant", response)
            log.debug("Stream completed, full response: " .. response)
          end)
          return
        end
        local ok, json = pcall(vim.json.decode, json_str)
        if ok and json.choices and json.choices[1].delta then
          local delta_content = json.choices[1].delta.content or json.choices[1].delta.reasoning_content or ""
          if delta_content ~= "" then
            response = response .. delta_content
            vim.schedule(function()
              if not ui.current_buf or not vim.api.nvim_buf_is_valid(ui.current_buf) then
                log.error("Chat buffer invalid during stream")
                return
              end
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
        else
          log.debug("Invalid JSON or no delta in stream chunk: " .. json_str)
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
          ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", false)
          if not ok then
            log.error("Failed to set modifiable false after non-200: " .. vim.inspect(set_err))
          end
          vim.notify("API Error: Status " .. res.status, vim.log.levels.ERROR)
        else
          -- Ensure final response is complete
          if response ~= "" then
            vim.schedule(function()
              local ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", true)
              if not ok then
                log.error("Failed to set modifiable true for final response: " .. vim.inspect(set_err))
              end
              ui.append_response("\n\n")
              ok, set_err = pcall(vim.api.nvim_buf_set_option, ui.current_buf, "modifiable", false)
              if not ok then
                log.error("Failed to set modifiable false after final response: " .. vim.inspect(set_err))
              end
              history.add("assistant", response)
              log.debug("Final response appended: " .. response)
            end)
          end
        end
      end)
    end,
  })
end

return { send_request = send_request }
