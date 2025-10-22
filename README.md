# grok.nvim
<a href="https://dotfyle.com/acris-software/grok-nvim-lua-grok"><img src="https://dotfyle.com/acris-software/grok-nvim-lua-grok/badges/plugins?style=for-the-badge" /></a>
<a href="https://dotfyle.com/acris-software/grok-nvim-lua-grok"><img src="https://dotfyle.com/acris-software/grok-nvim-lua-grok/badges/leaderkey?style=for-the-badge" /></a>
<a href="https://dotfyle.com/acris-software/grok-nvim-lua-grok"><img src="https://dotfyle.com/acris-software/grok-nvim-lua-grok/badges/plugin-manager?style=for-the-badge" /></a>
![grok-nvim](https://github.com/acris-software/grok-nvim/blob/dev/assets/images/grok-nvim.jpg)
![Star History Chart](https://api.star-history.com/svg?repos=acris-software/grok-nvim&type=Date)

## Project Overview
`grok-nvim` is a lightweight Neovim plugin for interacting with xAI's Grok models via their API. It provides a floating chat window for querying Grok, supports streaming responses, and offers a plug-and-play experience. Users install via a plugin manager, configure their xAI API key, and customize settings through `require("grok").setup(opts)`. Designed for developers, it enables seamless code analysis and interactive AI conversations within Neovim.

**Goals**:
- **Clean**: Modular, lightweight design with minimal dependencies.
- **Simple**: Intuitive setup and commands/keymaps for ease of use.
- **Performant**: Async operations for fast, non-blocking interactions.
- **Plug-and-Play**: Flexible configuration for model, temperature, and max tokens without code changes.

**Dependencies**: `plenary.nvim` (for curl and async operations).

## Features
- **Interactive Chat**: Use `:Grok <prompt>` or `<leader>gg` to query Grok (e.g., "Explain this Lua code"). Requires user-defined commands/keymaps in Neovim config.
- **Code Analysis**: Select code in visual mode and press `<leader>gg` to explain or refactor code. Requires user-defined keymaps.
- **Configurable**: Supports models (`grok-beta`, `grok-4`, `grok-3-mini`), customizable temperature, and max tokens.
- **Streaming Responses**: Real-time response rendering in the floating window.
- **Lightweight**: Minimal footprint with only `plenary.nvim` as a dependency.

## Installation
Obtain an xAI API key from [x.ai/api](https://x.ai/api). For free testing, use the Grok interface on [grok.com](https://grok.com) or [x.com](https://x.com).

### With lazy.nvim
Add to your Neovim plugin manager (e.g., in `lua/plugins.lua`):

```lua
return {
  {
    "acris-software/grok-nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("grok").setup({
        model = "grok-3-mini",
        base_url = "https://api.x.ai/v1",
        temperature = 0.7,
        max_tokens = 256,
      })
    end,
  },
}
```

## Usage

- Chat: **`:Grok`** "What is the meaning of life?" or <leader>gg to open a floating chat window.
- Code Analysis: In visual mode, select code and press <leader>gg or **`:GrokExplain`** to get explanations.
- Customize: Adjust `model`, `temperature`, or `max_tokens` in `setup()`.

Requirements

- Neovim 0.9.0+
- plenary.nvim
- xAI API key (free or paid tier, see x.ai/api)

Project Structure
```
grok-nvim/
├── assets/
│   ├── images/
│   │   └── grok-nvim.jpg
├── documenation/
│   ├── issue_tracker.md
│   └── roadmap.md
├── lua/
│   └──── grok/
│       ├── chat/
│       ├── history.lua  # Manages prompt history
│       │   ├── init.lua    # Chat module initialization
│       │   └── request.lua # Handles API requests
│       ├── log/
│       │   └── core.lua    # Logging utilities
│       ├── ui/
│       │   ├── keymaps.lua # Keymap definitions
│       │   ├── render.lua  # UI rendering logic
│       │   ├── state.lua   # UI state management
│       │   └── window.lua  # Floating window handling
│       ├── commands.lua    # Command definitions
│       ├── init.lua        # Plugin entry point
│       ├── log.lua         # Logging interface
│       ├── ui.lua          # UI module entry point
│       └── util.lua        # General utilities
├── .gitignore
├── LICENSE
└── README.md
```

## License
MIT License

## Contributing
Issues and PRs are welcome! Fork the repo, make changes, and submit a pull request.

Roadmap

Streaming responses with plenary.async.
LSP integration for code actions (e.g., "Grok refactor").
Prompt history integration with Telescope.nvim.
Support for Grok-4's tool-calling features.
