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
