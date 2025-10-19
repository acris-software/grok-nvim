-- ~/github.com/acris-software/grok-nvim/lua/grok/commands.lua

local M = {}

function M.setup_commands()
  vim.api.nvim_create_user_command("Grok", function(opts)
    require("grok").chat(opts.args)
  end, { nargs = "*", desc = "Chat with Grok" })
  vim.api.nvim_create_user_command("GrokVisual", function()
    local selected_text = require("grok.util").get_visual_selection()
    require("grok").chat(selected_text)
  end, { range = true, desc = "Chat with Grok using visual selection" })
  vim.api.nvim_create_user_command("GrokClear", function()
    require("grok.ui").close_chat_window()
  end, { desc = "Clear and close Grok chat window" })
  vim.api.nvim_create_user_command("GrokLog", function()
    local log_file = vim.fn.stdpath("data") .. "/grok.log"
    vim.cmd("edit " .. log_file)
  end, { desc = "View Grok log file" })
end

return M
