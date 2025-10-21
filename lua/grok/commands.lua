-- ~/github.com/acris-software/grok-nvim/lua/grok/commands.lua

local M = {}
function M.setup_commands()
  local log = require("grok.log")
  vim.api.nvim_create_user_command("Grok", function(opts)
    require("grok.ui").open_chat_window(function(input)
      require("grok.chat").chat(input)
    end)
    if opts.args and opts.args ~= "" then
      require("grok.chat").chat(opts.args)
    end
    log.debug("Grok command executed with args: " .. vim.inspect(opts.args))
  end, { nargs = "*", desc = "Chat with Grok" })
  vim.api.nvim_create_user_command("GrokVisual", function()
    local selected_text = require("grok.util").get_visual_selection()
    require("grok.ui").open_chat_window(function(input)
      require("grok.chat").chat(input)
    end)
    require("grok.chat").chat(selected_text)
    log.debug("GrokVisual command executed with selection: " .. selected_text)
  end, { range = true, desc = "Chat with Grok using visual selection" })
  vim.api.nvim_create_user_command("GrokClear", function()
    require("grok.chat").clear_history()
    local ui = require("grok.ui")
    if ui.current_buf and vim.api.nvim_buf_is_valid(ui.current_buf) then
      require("grok.ui.render").render_tab_content(ui.current_buf, function(input)
        require("grok.chat").chat(input)
      end)
    end
    log.info("GrokClear command executed")
  end, { desc = "Clear Grok chat history" })
  vim.api.nvim_create_user_command("GrokLog", function()
    local log_file = vim.fn.stdpath("data") .. "/grok.log"
    vim.cmd("edit " .. log_file)
    log.debug("GrokLog command executed, opening " .. log_file)
  end, { desc = "View Grok log file" })
  vim.api.nvim_create_user_command("GrokKeymaps", function()
    local ui = require("grok.ui")
    if ui.current_win and vim.api.nvim_win_is_valid(ui.current_win) then
      ui.set_current_tab(2)
      require("grok.ui.render").render_tab_content(ui.current_buf, function() end)
      log.debug("GrokKeymaps switched to tab 2 in UI")
    else
      ui.open_chat_window(function() end)
      ui.set_current_tab(2)
      require("grok.ui.render").render_tab_content(ui.current_buf, function() end)
      log.debug("GrokKeymaps opened UI and switched to tab 2")
    end
  end, { desc = "Show Grok-nvim keymaps" })
  vim.api.nvim_create_user_command("GrokUI", function()
    require("grok.ui").toggle_ui()
    log.debug("GrokUI command executed")
  end, { desc = "Toggle Grok UI" })
end
return M
