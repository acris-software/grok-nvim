local M = {}

function M.setup(opts)
  local curl = require("plenary.curl")
  local async = require("plenary.async")
  local ui = require("grok.ui")
  local chat = require("grok.chat")

  local function load_api_key()
    local home = os.getenv("HOME")
    local secrets_file = home .. "/.secrets"
    local file = io.open(secrets_file, "r")
    if not file then
      vim.notify("Could not open ~/.secrets file!", vim.log.levels.ERROR)
      return nil
    end
    for line in file:lines() do
      if line:match("^GROK_KEY=") then
        file:close()
        return line:gsub("^GROK_KEY=", "")
      end
    end
    file:close()
    vim.notify("GROK_KEY not found in ~/.secrets!", vim.log.levels.ERROR)
    return nil
  end

  local api_key = load_api_key() or vim.env.GROK_KEY or (opts and opts.api_key)
  M.config = vim.tbl_deep_extend("force", {
    api_key = api_key,
    model = "grok-3-mini",
    base_url = "https://api.x.ai/v1",
    temperature = 0.7,
    max_tokens = 256,
  }, opts or {})

  if not M.config.api_key then
    vim.notify("GROK_KEY not set in ~/.secrets, environment, or opts!", vim.log.levels.ERROR)
  end

  M.chat = chat.chat
end

return M
