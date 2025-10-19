# grok.nvim

A Neovim plugin for integrating xAI's Grok AI, providing interactive chat, code explanations, and refactoring directly in your editor.

## Features

- **Interactive Chat**: Use `:Grok <prompt>` or `<leader>gg` to query Grok (e.g., "Explain this Lua code"). (Note: Commands and keymaps must be defined in your Neovim config.)
- **Code Analysis**: Select code in visual mode and press `<leader>gg` to explain or refactor. (Note: Keymaps must be defined in your Neovim config.)
- **Configurable**: Supports `grok-beta` or `grok-4`, customizable temperature and max tokens.
- **Lightweight**: Built with `plenary.nvim` for HTTP requests, no heavy dependencies.

## Installation

Obtain an xAI API key from x.ai/api. For free testing, use the Grok interface on grok.com or x.com before integrating with the API.

### With lazy.nvim (General)

Add to your Neovim plugin manager (e.g., in `lua/plugins.lua`):

```lua
{
  "nicholasjordan/grok.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("grok").setup({
      api_key = vim.env.GROK_API_KEY,
      model = "grok-beta",
      base_url = "https://api.x.ai/v1",
      temperature = 0.7,
      max_tokens = 1024,
    })
  end,
}
```

## Usage

Chat: **`:Grok`** "Explain my Hyprland config" or <leader>gg to open a floating chat window.
Code Analysis: In visual mode, select code and press <leader>gg to get explanations orಯ
Customize: Adjust model, temperature, or max_tokens in the setup function.

Requirements

Neovim 0.9.0+
plenary.nvim
xAI API key (free or paid tier, see x.ai/api)

Project Structure
grok-nvim/
├── lua/
│   ├── grok/
│   │   ├── init.lua
│   │   ├── ui.lua
├── README.md
├── .gitignore
├── LICENSE

## License
MIT License

## Contributing
Issues and PRs are welcome! Fork the repo, make changes, and submit a pull request.

Roadmap

Streaming responses with plenary.async.
LSP integration for code actions (e.g., "Grok refactor").
Prompt history integration with Telescope.nvim.
Support for Grok-4's tool-calling features.
