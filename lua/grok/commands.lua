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
end

return M
