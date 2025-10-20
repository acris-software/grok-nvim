-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/keymaps.lua

local function set_keymaps(buf, win, callback)
  local log = require("grok.log")
  -- Normal Mode
  vim.api.nvim_buf_set_keymap(buf, "n", "<Tab>", "", {
    callback = function()
      log.debug("Tab pressed in normal mode, switching forward")
      require("grok.ui").current_tab = math.min(#require("grok.ui").tabs, require("grok.ui").current_tab + 1)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<S-Tab>", "", {
    callback = function()
      log.debug("Shift-Tab pressed in normal mode, switching backward")
      require("grok.ui").current_tab = math.max(1, require("grok.ui").current_tab - 1)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "1", "", {
    callback = function()
      log.debug("1 pressed in normal mode, switching to tab 1")
      require("grok.ui").current_tab = 1
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "2", "", {
    callback = function()
      log.debug("2 pressed in normal mode, switching to tab 2")
      require("grok.ui").current_tab = 2
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "3", "", {
    callback = function()
      log.debug("3 pressed in normal mode, switching to tab 3")
      require("grok.ui").current_tab = 3
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })
  -- Visual Mode
  vim.api.nvim_buf_set_keymap(buf, "v", "<Tab>", "", {
    callback = function()
      log.debug("Tab pressed in visual mode, switching forward")
      require("grok.ui").current_tab = math.min(#require("grok.ui").tabs, require("grok.ui").current_tab + 1)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "v", "<S-Tab>", "", {
    callback = function()
      log.debug("Shift-Tab pressed in visual mode, switching backward")
      require("grok.ui").current_tab = math.max(1, require("grok.ui").current_tab - 1)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "v", "1", "", {
    callback = function()
      log.debug("1 pressed in visual mode, switching to tab 1")
      require("grok.ui").current_tab = 1
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "v", "2", "", {
    callback = function()
      log.debug("2 pressed in visual mode, switching to tab 2")
      require("grok.ui").current_tab = 2
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "v", "3", "", {
    callback = function()
      log.debug("3 pressed in visual mode, switching to tab 3")
      require("grok.ui").current_tab = 3
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  -- Grok Tab specific: Send query with floating input in normal mode
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    callback = function()
      if require("grok.ui").current_tab ~= 1 then
        return
      end
      log.debug("CR pressed in normal mode, opening input prompt")
      require("grok.util").create_floating_input(function(input)
        if not input or input:match("^%s*$") then
          return
        end
        local ok, err = pcall(function()
          vim.api.nvim_buf_set_option(buf, "modifiable", true)
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "You: " .. input, "" })
          vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
          vim.api.nvim_buf_set_option(buf, "modifiable", false)
        end)
        if not ok then
          log.error("Failed to append user input: " .. vim.inspect(err))
          return
        end
        callback(input)
      end)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "i", "", {
    callback = function()
      if require("grok.ui").current_tab ~= 1 then
        return
      end
      log.debug("i pressed in normal mode, opening input prompt")
      require("grok.util").create_floating_input(function(input)
        if not input or input:match("^%s*$") then
          return
        end
        local ok, err = pcall(function()
          vim.api.nvim_buf_set_option(buf, "modifiable", true)
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "You: " .. input, "" })
          vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
          vim.api.nvim_buf_set_option(buf, "modifiable", false)
        end)
        if not ok then
          log.error("Failed to append user input: " .. vim.inspect(err))
          return
        end
        callback(input)
      end)
    end,
    noremap = true,
    silent = true,
  })
end
return { set_keymaps = set_keymaps }
