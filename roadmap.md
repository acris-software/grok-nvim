# grok-nvim Roadmap

## Project Overview
grok-nvim is a Neovim plugin for interacting with xAI's Grok models via their API. It provides a floating chat window for queries, supports streaming responses, and aims for a plug-and-play experience. Users install via a plugin manager, set their API key, and customize via `require("grok").setup(opts)`.

**Goals**:
- **Clean**: Minimalist code (<500 LOC total), modular files.
- **Simple**: Easy setup; intuitive commands/keymaps.
- **Performant**: Async operations; lightweight (only plenary.nvim dep for curl/async).
- **Plug-and-Play**: Override model/tokens/temperature in setup; no code changes needed.

**Dependencies**: plenary.nvim (for curl, async).

**Version Target**:
- Incremental releases: 0.1.0 -> 0.1.1 -> 0.1.2, etc., for bug fixes and minor additions.
- 0.5.0: Alpha phase (core functionality stable, basic testing done).
- 0.7.0: Beta phase (polish features added, user feedback incorporated, edge cases handled).
- 1.0.0: MVP (Minimum Viable Product) - All must-haves complete, key nice-to-haves, full error handling, UI customizations, basic docs/README, and initial release to GitHub.
- Future: v1.x for patches, v2.0 for advanced features.
We prioritize quality, performance, and reliability—no rushing. Each increment includes testing, logging enhancements, and code reviews.

## Features
These are all the planned features, categorized by priority. They ensure stability, usability, and extensibility. Features are assigned to specific versions in the Roadmap section below.

### Core Features
These ensure stability and basic usability.
1. **Flexible Configuration System**
   - Description: Expand `setup(opts)` to support more overrides; add validation.
   - Implementation Notes:
     - In `init.lua`: Add `stream` (bool, default true) to toggle streaming; use pcall/type checks for validation (e.g., if model not string, notify and default).
     - Support model aliases by adding a table in config (e.g., if opts.model = "mini", map to "grok-3-mini"; error on invalid alias).
     - How to Achieve: Extend `tbl_deep_extend` with post-processing for aliases/validation; test with invalid opts to ensure notifications.
     - Dependencies: None.

2. **Improved Error Handling and Feedback**
   - Description: Handle API failures gracefully; add retries.
   - Implementation Notes:
     - In `chat.lua`: Wrap curl.post in pcall; on error (e.g., 429 rate limit or 5xx server error), retry once after a delay (use plenary.async.sleep).
     - Show UI notifications (vim.notify) for retries/errors; integrate with log.error for debug mode.
     - Log full errors with context (e.g., request body).
     - How to Achieve: Add a retry function around curl; test with mocked errors (plenary.test for unit tests).
     - Dependencies: Existing log.lua.

3. **Multi-Turn Chat Persistence**
   - Description: Maintain conversation history per session.
   - Implementation Notes:
     - In `chat.lua`: Add local `history = {}` table.
     - On input: Append {role="user", content=input} to history; send full history to API.
     - Append assistant response to history.
     - Clear on :GrokClear.
   - Dependencies: ui.lua for appending responses.

4. **Command to Print Keymaps (:GrokKeymaps)**
   - Description: List chat window keymaps via command.
   - Implementation Notes:
     - In `commands.lua`: Add `vim.api.nvim_create_user_command("GrokKeymaps", function() ... vim.notify(table_of_keymaps) end)`.
     - List: "<CR> Send query", "<Esc> Close window".
   - Dependencies: None.

### Polish Features
Add after core; enhance without complexity.
1. **Model-Agnostic Tweaks**
   - Description: Handle model-specific behaviors; presets.
   - Implementation Notes: In `init.lua`, map aliases to API models.

2. **Visual Mode Enhancements**
   - Description: Custom prompts for :GrokVisual.
   - Implementation Notes: In `commands.lua`/`util.lua`: Add config.visual_prompt (default "Explain: "); prepend to selection.

3. **Logging and Debugging Toggle**
   - Description: Verbose logs when debug=true.
   - Implementation Notes: Already gated; add more details (e.g., full JSON in stream).

4. **Auto-Completion Integration**
   - Description: Optional nvim-cmp source for prompts.
   - Implementation Notes: In `init.lua`: If cmp loaded, register source with common prompts (e.g., "What is...").

### Advanced Features
Defer until v1 stable; add based on user feedback.
1. **Session Management**
   - Description: Save/load chats to files.
   - Implementation Notes: New commands :GrokSave/:GrokLoad; store JSON in stdpath("data").

2. **UI Customizations**
   - Description: Configurable window (size, border).
   - Implementation Notes: In `ui.lua`: Use config.win_opts; merge with defaults.

3. **Rate Limiting and Caching**
   - Description: Throttle calls; cache responses.
   - Implementation Notes: Use vim.job for timers; store in vim.fn.stdpath("cache").

4. **Plugin Manager Compatibility**
   - Description: Lazy-loading spec.
   - Implementation Notes: Add lazy.nvim example in README.

## Roadmap
This outlines the sequential rollout by version, with overviews and assigned features. Each version builds on the previous, including testing and code reviews.

### v0.1.x
#### v0.1.0 (Basic)
Basic chat, streaming, UI, logging, visual selection. Fixes for reasoning/modifiability. Multi-turn persistence and logging enhancements.
**Multi-Turn Chat Persistence** (Target: 0.1.0)
   - Description: Maintain conversation history per session.
   - Implementation Notes:
     - In `chat.lua`: Add local `history = {}` table.
     - On input: Append {role="user", content=input} to history; send full history to API.
     - Append assistant response to history.
     - Clear on :GrokClear.
   - Dependencies: ui.lua for appending responses.
   - Status: [✓] Implemented.

**Logging and Debugging Toggle** (Target: 0.1.0)
   - Description: Verbose logs when debug=true.
   - Implementation Notes: Already gated; add more details (e.g., full JSON in stream).
   - Status: [✓] Implemented and enhanced with levels (debug, info, error) and throttling.

**Plugin Manager Compatibility** (Target: 0.1.0)
   - Description: Lazy-loading spec.
   - Implementation Notes: Add lazy.nvim example in README.
   - Status: [✓] Implicitly supported.

*Recent commits*
- [grok-nvim] 0.1.0-119-p: Modularized chat.lua

- [grok-nvim] 0.1.0-118-p: 
feat: Multi-turn chat persistence for v0.1.0

- Add `history` table in `chat.lua` for session persistence.
- Append user/assistant messages, send to API.
- Update `:GrokClear` to reset history, close window.
- Ensure `render.lua` keeps chat tab modifiable.
- Support v0.1.0: chat, streaming, UI, logging, selection.

Test:
- History persists in session and API.
- `:GrokClear` resets and closes.
- Chat tab stays modifiable, UI responsive.
- Logging and `:GrokVisual` work.

#### v0.1.1
UI Polish - Centered Input + Multi-line Prompts + Auto-scrolling.
**Command to Print Keymaps (:GrokKeymaps)** (Target: 0.1.1)
   - Description: List chat window keymaps via command.
   - Implementation Notes:
     - In `commands.lua`: Add `vim.api.nvim_create_user_command("GrokKeymaps", function() ... vim.notify(table_of_keymaps) end)`.
     - List: "<CR> Send query", "<Esc> Close window".
     - What if we change <CR> to <?> for send query instead?
   - Dependencies: None.
   - Status: [✓] Implemented (integrated with UI tab 2 for in-window view).

**Issue 4: Centered Chat Input Box + Configurable Location** (Target: 0.1.1)
   - Problem: User chat box input pops up in weird space, cutting off text.
   - Analysis: UI/UX needs improvement; prompt should scale with typing; be configurable.
   - Solution: Add config.prompt_position (left/center/right); real-time updates via config tab.
   - Status: [✓] Implemented.
   - Implementation Notes:
     - In `init.lua`: Add `prompt_position = "center"` (options: "left", "center", "right")
     - In `chat/init.lua`: Replace vim.ui.input with floating window using vim.api.nvim_open_win
     - Window config: width = vim.o.columns * 0.6, height = 3-8 lines (auto-grow), border = "rounded"
     - Position calculation: center = {row = (vim.o.lines - height) / 2, col = (vim.o.columns - width) / 2}
     - Real-time config tab updates: Watch config.prompt_position changes, re-open input window
     - Multi-line support: Use vim.api.nvim_buf_set_lines for input buffer, <CR> to submit
     - Auto-scroll: vim.api.nvim_win_set_cursor to bottom after new messages
     - Max length: config.max_prompt_length = 2048 (model-aware defaults)
   - Dependencies: Existing ui/window.lua for floating window patterns.
   - Test Plan:
     - [ ] Input appears centered, scales to 3+ lines
     - [ ] Config tab changes position instantly  
     - [ ] Multi-line input submits correctly
     - [ ] Auto-scrolls to bottom on responses
     - [ ] Respects max length per model

**UI Auto-scrolling Enhancement** (Target: 0.1.1)
   - Description: Automatically scroll to bottom on new messages.
   - Implementation Notes:
     - In `ui/render.lua.append_response`: Always set cursor to {line_count, 0}
     - In `ui/render.lua.render_tab_content`: Set cursor to bottom for tab 1
   - Status: [ ] Not implemented.
   - Dependencies: Existing cursor positioning code.

**Multi-line Input Support** (Target: 0.1.1)
   - Description: Replace single-line vim.ui.input with resizable floating input window.
   - Implementation Notes:
     - Create dedicated input buffer/window in `chat/init.lua`
     - Keymaps: <CR> = submit, <Esc> = cancel, <C-u> = clear
     - Auto-grow height from 3 to 8 lines based on content
   - Status: [ ] Not implemented.
   - Dependencies: ui/window.lua patterns.

**Issue 5: Inconsistent Prompt Box Display** (Target: 0.1.1)
   - Problem: Prompt box only displays properly on first :Grok; reverts to old style after.
   - Analysis: Likely state issue in chat/init.lua or ui/window.lua; floating input not reinitialized.
   - Solution: Ensure util.create_floating_input called consistently on each prompt.
   - Status: [✓] Verified fixed.

**Issue 6: Verify Max Prompt Length for Models** (Target: 0.1.1)
   - Problem: Current max 131072 for Grok-3-mini; confirm accuracy.
   - Analysis: From x.ai docs, Grok-3-mini context window is 131072 tokens (confirmed).
   - Solution: Update util.get_model_max_tokens with verified values; add more models.
   - Status: [✓] Verified (131072 tokens); implement dynamic if API provides.

**Issue 7: Grok Prevents Smooth Neovim Exit** (Target: 0.1.1)
   - Problem: Requires :qa! to exit Neovim after using Grok.
   - Analysis: Likely unclosed buffers/windows or autocmds; check ui/window.lua close logic.
   - Solution: Ensure close_chat_window cleans up properly; add vim.api.nvim_buf_delete on exit.
   - Status: [✓] Verified fixed.

#### v0.1.2
**Config expansions**
**Flexible Configuration System** (Target: 0.1.2)
   - Description: Expand `setup(opts)` to support more overrides; add validation.
   - Implementation Notes:
     - In `init.lua`: Add `stream` (bool, default true) to toggle streaming; use pcall/type checks for validation (e.g., if model not string, notify and default).
     - Support model aliases by adding a table in config (e.g., if opts.model = "mini", map to "grok-3-mini"; error on invalid alias).
     - How to Achieve: Extend `tbl_deep_extend` with post-processing for aliases/validation; test with invalid opts to ensure notifications.
   - Dependencies: None.
   - Status: [✓] Basic config exists; [✓] Loads API key from file/env; [ ] Add stream/aliases/validation.

**Improved Error Handling for UI** (Target: 0.1.2)
   - Description: Enhance error feedback in UI elements like input prompts and config tab.
   - Implementation Notes:
     - In `chat/init.lua` and `ui/render.lua`: Add try-catch (pcall) around UI operations; display vim.notify on failures.
     - Integrate with log.lua for detailed errors.
     - Specific: Handle invalid prompt lengths with warnings + character counter in input window.
   - Status: [ ] Not implemented.
   - Dependencies: Existing log.lua and error handling in core.

**Config Tab Real-time Updates** (Target: 0.1.2)
   - Description: Changes in config tab apply instantly without restart.
   - Implementation Notes:
     - Use vim.api.nvim_create_autocmd("BufLeave", {pattern = "*grok-config*", callback = apply_config})
     - Reload relevant options: prompt_position, theme, keymaps
     - User defined basic config in their ~/.config/nvim/lua/grok.lua must not be changed automatically.
   - Status: [ ] Not implemented.
   - Dependencies: Existing config display in tab 3.

**User Config Separation & Hidden Options** (Target: 0.1.2)
   - Description: Distinguish user-defined grok.lua basics from in-plugin configs; define visible/hidden options.
   - Implementation Notes:
     - In `init.lua`: Load basics (api_key, model, etc.) from user grok.lua; prevent overwrites.
     - Hidden: Model-specific limits (e.g., max_prompt_length derived from API docs: Grok-3-mini 131072 tokens context, cap prompts at 131072 input).
     - Visible: UI options like prompt_position.
     - In input window: Add real-time char counter (e.g., "123/131072") via autocmd TextChangedI; warn/trim on exceed.
   - Status: [ ] Not implemented.
   - Dependencies: Flexible Config System (partial from v0.1.2).


#### v0.1.3
**Enhanced Logging System + Performance + Debug Flag**
**Expand and Modularize Logging** (Target: v0.1.3)
   - Description: Handle debug state to only print debug/logs IF debug is set to true in config.
   - Implementation Notes:
     - v0.1.1 introduced basic util.lua that incorporated this concept in an effort to improve performance while maintaining debugging ability
     - Key is to keep things lightweight.
   - Dependencies: Modularize log.lua into ~/grok/log/log.lua, ~/grok/log/logger.lua (name appropriately and modularize appropriately)
   - Status: [ ] Not implemented

**Improved Error Handling and Feedback** (Target: v0.1.3)
   - Description: Handle API failures gracefully; add retries.
   - Implementation Notes:
     - In `chat.lua`: Wrap curl.post in pcall; on error (e.g., 429 rate limit or 5xx server error), retry once after a delay (use plenary.async.sleep).
     - Show UI notifications (vim.notify) for retries/errors; integrate with log.error for debug mode.
     - Log full errors with context (e.g., request body).
     - How to Achieve: Add a retry function around curl; test with mocked errors (plenary.test for unit tests).
   - Dependencies: New modular log/ directory structure.
   - Status: [✓] Basic errors handled; [ ] **FULL LOGGING + RETRIES + PERFORMANCE**.

**Log Directory Expansion** (Target: 0.1.3)
   - Description: Modularize log/ if needed for UI error handling.
   - Implementation Notes:
     - Split core.lua into log/levels.lua (debug/info/error), log/rotate.lua (size management).
     - Keep minimal: Only expand if UI errors require more granular logging.
   - Status: [ ] Not implemented (defer if not critical).
   - Dependencies: Existing log.lua.

**Log Directory Expansion** (Target: 0.1.3)
   - Description: Modularize log/ if needed for UI error handling.
   - Implementation Notes:
     - Split core.lua into log/levels.lua (debug/info/error), log/rotate.lua (size management).
     - Keep minimal: Only expand if UI errors require more granular logging.
   - Status: [ ] Not implemented (defer if not critical).
   - Dependencies: Existing log.lua.

#### v0.1.4
Model presets.
**Model-Agnostic Tweaks** (Target: 0.1.4)
   - Description: Handle model-specific behaviors; presets.
   - Implementation Notes: In `init.lua`, map aliases to API models.
   - Status: [✓] Handles reasoning_content in stream handler; [ ] Presets/aliases.

#### v0.1.5
Visual mode custom prompts.
**Visual Mode Enhancements** (Target: 0.1.5)
   - Description: Custom prompts for :GrokVisual.
   - Implementation Notes: In `commands.lua`/`util.lua`: Add config.visual_prompt (default "Explain: "); prepend to selection.
   - Status: [✓] Basic visual with get_visual_selection in util.lua and :GrokVisual command; [ ] Custom prompts/config.

#### v0.1.6
Auto-completion integration.
**Auto-Completion Integration** (Target: 0.1.6)
   - Description: Optional nvim-cmp source for prompts.
   - Implementation Notes: In `init.lua`: If cmp loaded, register source with common prompts (e.g., "What is...").
   - Status: [ ] Not implemented.

### v0.2.x
#### v0.2.0
Session management.
**Session Management** (Target: 0.2.0)
   - Description: Save/load chats to files.
   - Implementation Notes: New commands :GrokSave/:GrokLoad; store JSON in stdpath("data").
   - Status: [ ] Not implemented.

#### v0.2.1
UI customizations.
**UI Customizations** (Target: 0.2.1)
   - Description: Configurable window (size, border).
   - Implementation Notes: In `ui.lua`: Use config.win_opts; merge with defaults.
   - Status: [✓] Basic window with fixed size/border; [✓] Tabbed UI enhancement; [ ] Configurable opts.

#### v0.2.2
Rate limiting and caching.
**Rate Limiting and Caching** (Target: 0.2.2)
   - Description: Throttle calls; cache responses.
   - Implementation Notes: Use vim.job for timers; store in vim.fn.stdpath("cache").
   - Status: [ ] Not implemented.

### v0.3.x
#### v0.3.0
Advanced error handling extensions (e.g., backoff strategies for retries, user-configurable retry limits).

#### v0.3.1
Additional polish features like theme integration for UI or extended model presets.

#### v0.3.2
Introduce basic CI linting and initial unit test setup.

#### v0.3.3
Edge case handling for API responses (e.g., empty streams, malformed JSON).

### v0.4.x
#### v0.4.0
Comprehensive unit testing with plenary.test_harness (e.g., mock API for chat/streaming).

#### v0.4.1
Manual testing scripts and benchmarks (:time for UI/performance).

#### v0.4.2
Pre-alpha review: Fix bugs, refine docs/README, add CI for luacheck/testing.

### v0.5.x
#### v0.5.0
Alpha - All must-haves + polish; initial testing.

### v0.6.x
#### v0.6.0
Post-alpha polish (e.g., performance optimizations).

#### v0.6.1
Additional feedback-driven tweaks.

### v0.7.x
#### v0.7.0
Beta - User feedback, bug fixes, edge cases.

### v1.0.x
#### v1.0.0
MVP - Complete.

## Changes Log
  - 2025-10-19: Reviewed code; created this doc. [Initial]
  - 2025-10-19: Implemented multi-turn chat persistence; added :GrokKeymaps command; enhanced logging with levels and throttling; modularized UI and log; added tabbed UI for better navigation.
  - 2025-10-19: Reviewed current code; updated statuses (e.g., partial for config/error handling); reorganized plan with v0.3.x (advanced extensions) and v0.4.x (testing focus before alpha).
  - 2025-10-20: Added bug fixes for v0.1.2: Inconsistent prompt box, verified max length (131072 for Grok-3-mini), Neovim exit issue.

## Testing and Release Plan
- **Unit Tests**: Use plenary.test_harness for API mocks (e.g., test streaming parsing).
- **Manual Tests**: :Grok queries; visual mode; error scenarios (bad key).
- **Benchmark**: Use :time for UI open/response append (<100ms target).
- **Release Steps**:
  1. Update version in init.lua/README.
  2. Git tag (e.g., v1.0).
  3. Push to GitHub; announce on Neovim Reddit/Discord.
- **CI**: Add GitHub Actions for luacheck/linting.

## Contributions
- Use issues for bugs/features.
- PRs: Branch from master; target one feature.
- License: MIT.
This doc is living—update as needed!
