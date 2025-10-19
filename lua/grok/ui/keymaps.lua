-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/keymaps.lua

local function set_keymaps(buf, win, callback)
  -- Keymaps for tabs (normal mode)
  vim.api.nvim_buf_set_keymap(buf, "n", "<Left>", "", {
    callback = function()
      require("grok.ui").current_tab = math.max(1, require("grok.ui").current_tab - 1)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Right>", "", {
    callback = function()
      require("grok.ui").current_tab = math.min(3, require("grok.ui").current_tab + 1)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "1", "", {
    callback = function()
      require("grok.ui").current_tab = 1
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "2", "", {
    callback = function()
      require("grok.ui").current_tab = 2
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "3", "", {
    callback = function()
      require("grok.ui").current_tab = 3
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })

  -- Grok-Tab only
  vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
    callback = function()
      if require("grok.ui").current_tab ~= 1 then
        return
      end
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local input = lines[#lines] or ""
      if input:match("^%s*$") then
        return
      end
      vim.api.nvim_buf_set_lines(buf, -2, -1, false, { "", "You: " .. input, "" })
      vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      vim.api.nvim_command("startinsert")
      callback(input)
    end,
  })
end

return { set_keymaps = set_keymaps }
