-- ~/github.com/acris-software/grok-nvim/lua/grok/commands.lua

local M = {}
function M.setup_commands()
  local log = require("grok.log")
  log.debug("=== COMMANDS: Setting up commands")

  vim.api.nvim_create_user_command("Grok", function(opts)
    log.debug("=== COMMANDS: Grok called with args: " .. vim.inspect(opts.args))
    require("grok.chat").chat(opts.args)
    log.debug("Grok command executed with args: " .. vim.inspect(opts.args))
  end, { nargs = "*", desc = "Chat with Grok" })

  vim.api.nvim_create_user_command("GrokVisual", function()
    local selected_text = require("grok.util").get_visual_selection()
    log.debug("=== COMMANDS: GrokVisual called with: " .. selected_text)
    require("grok.chat").chat(selected_text)
    log.debug("GrokVisual command executed with selection: " .. selected_text)
  end, { range = true, desc = "Chat with Grok using visual selection" })

  vim.api.nvim_create_user_command("GrokClear", function()
    log.debug("=== COMMANDS: GrokClear called")
    require("grok.ui").close_chat_window()
    require("grok.chat").clear_history()
    log.info("GrokClear command executed")
  end, { desc = "Clear and close Grok chat window" })

  vim.api.nvim_create_user_command("GrokLog", function()
    local log_file = vim.fn.stdpath("data") .. "/grok.log"
    log.debug("=== COMMANDS: GrokLog called, opening " .. log_file)
    vim.cmd("edit " .. log_file)
    log.debug("GrokLog command executed, opening " .. log_file)
  end, { desc = "View Grok log file" })

  vim.api.nvim_create_user_command("GrokKeymaps", function()
    local ui = require("grok.ui")
    log.debug("=== COMMANDS: GrokKeymaps called")
    if ui.current_win and vim.api.nvim_win_is_valid(ui.current_win) then
      ui.current_tab = 2
      require("grok.ui.render").render_tab_content(ui.current_buf, function() end)
      log.debug("GrokKeymaps switched to tab 2 in UI")
    else
      local keymaps = {
        "In Grok Chat Window:",
        " <CR> or i: Open input prompt",
        " <Esc>: Close window",
      }
      vim.notify(table.concat(keymaps, "\n"), vim.log.levels.INFO)
      log.debug("GrokKeymaps notified keymaps")
    end
  end, { desc = "List Grok-nvim keymaps" })

  log.debug("=== COMMANDS: All commands setup complete")
end
return M
