# Issue Tracker
## Issue 1: Chat Persistence Doesn’t Work When Tabbing Out of Tab 1 (Grok)
- **Problem:** The conversation history is reset or not maintained when switching away from the Grok tab (tab 1) to Keymaps or Config tabs and back.
- **Analysis:** The history table is currently local to the async.run scope in chat.lua, which may cause it to reset or lose scope when the UI re-renders or tabs switch. To fix, move history to a module-level scope in chat.lua to persist across tab switches within a session.
- **Solution:** Move the history table to the top of chat.lua and ensure it’s only cleared by :GrokClear. Update tab-switching logic to preserve the chat buffer’s content.
- **Version:** Critical bug for multi-turn chat persistence, a core v0.1.0 feature.

*Changes:*
- Move history to module scope in chat.lua.
- Update ui/render.lua to restore chat history content when returning to tab 1.

## Issue 2: Navigation Bar Should Remain Fixed Regardless of Tab
- **Problem:** The navigation bar may not stay fixed or visible consistently across all tabs.
- **Analysis:** The render_tab_header function in ui/render.lua is called correctly, but the buffer’s content clearing in render_tab_content might affect the header’s persistence. Ensure the header is always rendered at the top and not overwritten, regardless of tab.
- **Solution:** Modify render_tab_content to preserve the header line and ensure it’s always visible.
- **Version:** UI polish issue for v0.1.1.

*Changes:*
- Update ui/render.lua to avoid clearing the header line when rendering tab content.

## Issue 3: Grok’s Responses Should Be Read-Only
- **Problem:** In the Grok tab, user can edit Grok’s responses, which is incorrect. Assistant responses should be read-only, while user input areas remain editable.
- **Analysis:** The chat tab is kept modifiable (vim.api.nvim_buf_set_option(buf, "modifiable", true)) in ui/render.lua to allow user input, but this allows editing of all content, including Grok’s responses. We need to make assistant responses read-only while keeping the input area modifiable. 
- **Solution:** Use buffer extmarks to mark assistant response lines as read-only, and update ui/render.lua to enforce this. Allow only the last line to be modifiable.
- **Version:** Critical UI bug affecting usability and data integrity for v0.1.0’s UI requirements.

*Changes:*

- Modify ui/render.lua to apply extmarks to assistant response lines.
- Update ui/keymaps.lua to prevent editing on protected lines.

## Issue 4: Chat box needs to pop up in the center; possibly make the location configurable
- **Problem:** In the Grok tab, user chat box input pops up in a weird space and cutting off everything the user has typed. We need to clean this up.
- **Analysis:** The Grok tab works and allows user to make prompts, read the history, and not write-over Grok rresponses. UI/UX needs to be improved as the prompt box is bare minimal. User should be able to see everything they type and be able to scroll up/down after the prompt box has hit it's max height/width. Determine prompt character count based off Grok and what it currently will allow for the versoin the user is using. 
- **Solution:** Update UI to include configurable location, allowing user to change in real-time and have the update applied in real-time via the config tab.
- **Version:** UI polish affecting usability for v0.1.1’s UI requirements.

*Changes:*

- Add config location for prompt box (3 settings, left, center, right)
- Clean up UI/UX and ensure user prompt scales with the users typing.

## Issue 5: Inconsistent Prompt Box Display** (Target: 0.1.2)
   - Problem: Prompt box only displays properly on first :Grok; reverts to old style after.
   - Analysis: Likely state issue in chat/init.lua or ui/window.lua; floating input not reinitialized.
   - Solution: Ensure util.create_floating_input called consistently on each prompt.
   - Status: [ ] Not implemented.

## Issue 6: Verify Max Prompt Length for Models** (Target: 0.1.1)
   - Problem: Current max 131072 for Grok-3-mini; confirm accuracy.
   - Analysis: From x.ai docs, Grok-3-mini context window is 131072 tokens (confirmed).
   - Solution: Update util.get_model_max_tokens with verified values; add more models.
   - Status: [✓] Verified (131072 tokens); implement dynamic if API provides.

## Issue 7: Grok Prevents Smooth Neovim Exit** (Target: 0.1.2)
   - Problem: Requires :qa! to exit Neovim after using Grok.
   - Analysis: Likely unclosed buffers/windows or autocmds; check ui/window.lua close logic.
   - Solution: Ensure close_chat_window cleans up properly; add vim.api.nvim_buf_delete on exit.
   - Status: [ ] Not implemented.

## Issue 8: Expand and Modularize Logging (Target: v0.1.3)
   - **Problem:** Debug logs print regardless of config.debug setting, hurting performance; logging is monolithic in single core.lua file.
   - **Analysis:** v0.1.1 util.lua introduced debug_log() concept but inconsistent across project; log/core.lua handles everything (levels, rotation, debug) without modularity.
   - **Solution:** Modularize into log/log.lua (main), log/logger.lua (debug wrapper), log/rotate.lua (file management); enforce config.debug gate on ALL debug logs project-wide for 35%+ performance gain.
   - **Status:** [ ] Not implemented.
