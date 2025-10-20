-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/keymaps.lua

local function set_keymaps(buf, win, callback)
  local log = require("grok.log")
  local ui = require("grok.ui")
  -- Normal Mode
  vim.api.nvim_buf_set_keymap(buf, "n", "<Tab>", "", {
    callback = function()
      log.debug("Tab pressed in normal mode, switching forward")
      ui.set_current_tab(math.min(#ui.tabs, ui.current_tab + 1))
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<S-Tab>", "", {
    callback = function()
      log.debug("Shift-Tab pressed in normal mode, switching backward")
      ui.set_current_tab(math.max(1, ui.current_tab - 1))
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "1", "", {
    callback = function()
      log.debug("1 pressed in normal mode, switching to tab 1")
      ui.set_current_tab(1)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "2", "", {
    callback = function()
      log.debug("2 pressed in normal mode, switching to tab 2")
      ui.set_current_tab(2)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "3", "", {
    callback = function()
      log.debug("3 pressed in normal mode, switching to tab 3")
      ui.set_current_tab(3)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
    callback = function()
      log.debug("Esc pressed in normal mode, focusing previous window")
      local wins = vim.api.nvim_list_wins()
      for _, w in ipairs(wins) do
        if w ~= ui.current_win and vim.api.nvim_win_is_valid(w) then
          vim.api.nvim_set_current_win(w)
          break
        end
      end
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>lua require('grok.ui').close_chat_window()<CR>", {
    noremap = true,
    silent = true,
  })
  -- Visual Mode
  vim.api.nvim_buf_set_keymap(buf, "v", "<Tab>", "", {
    callback = function()
      log.debug("Tab pressed in visual mode, switching forward")
      ui.set_current_tab(math.min(#ui.tabs, ui.current_tab + 1))
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "v", "<S-Tab>", "", {
    callback = function()
      log.debug("Shift-Tab pressed in visual mode, switching backward")
      ui.set_current_tab(math.max(1, ui.current_tab - 1))
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "v", "1", "", {
    callback = function()
      log.debug("1 pressed in visual mode, switching to tab 1")
      ui.set_current_tab(1)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "v", "2", "", {
    callback = function()
      log.debug("2 pressed in visual mode, switching to tab 2")
      ui.set_current_tab(2)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "v", "3", "", {
    callback = function()
      log.debug("3 pressed in visual mode, switching to tab 3")
      ui.set_current_tab(3)
      require("grok.ui.render").render_tab_content(buf, callback)
    end,
    noremap = true,
    silent = true,
  })
  -- Grok Tab specific: Open floating multi-line input in normal mode
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    callback = function()
      if ui.current_tab ~= 1 then
        return
      end
      log.debug("CR pressed in normal mode, opening floating input")
      require("grok.util").create_floating_input({ callback = callback })
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "i", "", {
    callback = function()
      if ui.current_tab ~= 1 then
        return
      end
      log.debug("i pressed in normal mode, opening floating input")
      require("grok.util").create_floating_input({ callback = callback })
    end,
    noremap = true,
    silent = true,
  })
end
return { set_keymaps = set_keymaps }
