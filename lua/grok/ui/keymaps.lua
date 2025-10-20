-- ~/github.com/acris-software/grok-nvim/lua/grok/ui/keymaps.lua

local function set_keymaps(buf, win, callback)
  local log = require("grok.log")
  log.debug("=== KEYMAPS: Setting keymaps for buf " .. buf)

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
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "<Esc>",
    "<cmd>lua require('grok.ui').close_chat_window()<CR>",
    { noremap = true, silent = true }
  )

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
      local current_tab = require("grok.ui").current_tab
      log.debug("=== KEYMAPS: CR pressed, tab=" .. current_tab)
      if current_tab ~= 1 then
        log.debug("CR ignored - not in tab 1")
        return
      end
      log.debug("=== KEYMAPS: CR → Opening floating input")
      require("grok.util").create_floating_input({})
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "i", "", {
    callback = function()
      local current_tab = require("grok.ui").current_tab
      log.debug("=== KEYMAPS: i pressed, tab=" .. current_tab)
      if current_tab ~= 1 then
        log.debug("i ignored - not in tab 1")
        return
      end
      log.debug("=== KEYMAPS: i → Opening floating input")
      require("grok.util").create_floating_input({})
    end,
    noremap = true,
    silent = true,
  })
end
return { set_keymaps = set_keymaps }
