local M = {}
local api = vim.api

---@class TabBuffersState
---@field buffers integer[]
---@field members table<integer, boolean>

---@type table<integer, TabBuffersState>
local tabs = {}
local pause_depth = 0
local tracking_generation = 0
local redraw_pending = false

---Whether the configured tabline uses tab-local buffer integration.
function M.enabled()
  local options = vim.g.options
  local tab = options and options.tab
  return tab ~= nil and tab.choices[tab.chosen] == 'bufferline'
end

local function resolve_tab(tabpage)
  if tabpage == nil or tabpage == 0 then
    return api.nvim_get_current_tabpage()
  end
  return tabpage
end

local function resolve_buf(bufnr)
  if bufnr == nil or bufnr == 0 then
    return api.nvim_get_current_buf()
  end
  return bufnr
end

local function valid_tab(tabpage)
  return type(tabpage) == 'number' and api.nvim_tabpage_is_valid(tabpage)
end

local function eligible(bufnr)
  if type(bufnr) ~= 'number' or not api.nvim_buf_is_valid(bufnr) then
    return false
  end
  local buftype = vim.bo[bufnr].buftype
  return vim.bo[bufnr].buflisted and (buftype == '' or buftype == 'acwrite')
end

local function redraw()
  if redraw_pending then
    return
  end
  redraw_pending = true
  vim.schedule(function()
    redraw_pending = false
    vim.cmd 'redrawtabline'
  end)
end

---Return a copy in insertion order. Hidden buffers remain members.
---@param tabpage? integer Tabpage handle; nil or 0 means the current tab.
---@return integer[]
function M.list(tabpage)
  tabpage = resolve_tab(tabpage)
  local state = valid_tab(tabpage) and tabs[tabpage] or nil
  local buffers = {}
  if state then
    for _, bufnr in ipairs(state.buffers) do
      if eligible(bufnr) then
        buffers[#buffers + 1] = bufnr
      end
    end
  end
  return buffers
end

---@param tabpage? integer
---@param bufnr? integer Buffer handle; nil or 0 means the current buffer.
---@return boolean
function M.contains(tabpage, bufnr)
  tabpage, bufnr = resolve_tab(tabpage), resolve_buf(bufnr)
  local state = valid_tab(tabpage) and tabs[tabpage] or nil
  return state ~= nil and state.members[bufnr] == true and eligible(bufnr)
end

---Attach a listed normal/acwrite buffer, including an unnamed editing buffer.
---A buffer can belong to multiple tabs. No buffer options are changed.
---@param tabpage? integer
---@param bufnr? integer
---@return boolean changed
function M.attach(tabpage, bufnr)
  tabpage, bufnr = resolve_tab(tabpage), resolve_buf(bufnr)
  if not valid_tab(tabpage) or not eligible(bufnr) then
    return false
  end
  local state = tabs[tabpage]
  if not state then
    state = { buffers = {}, members = {} }
    tabs[tabpage] = state
  end
  if state.members[bufnr] then
    return false
  end
  state.buffers[#state.buffers + 1] = bufnr
  state.members[bufnr] = true
  redraw()
  return true
end

---Remove membership only; does not switch windows or delete the buffer.
---Displaying the buffer in this tab again can automatically reattach it.
---@param tabpage? integer
---@param bufnr? integer
---@return boolean changed
function M.detach(tabpage, bufnr)
  tabpage, bufnr = resolve_tab(tabpage), resolve_buf(bufnr)
  local state = tabs[tabpage]
  if not state or not state.members[bufnr] then
    return false
  end
  state.members[bufnr] = nil
  for i, buf in ipairs(state.buffers) do
    if buf == bufnr then
      table.remove(state.buffers, i)
      break
    end
  end
  redraw()
  return true
end

---Delete a buffer owned by one tab; otherwise close only this tab's view.
---Unsaved changes prevent deletion of an exclusively owned buffer.
---@param tabpage? integer
---@param bufnr? integer
---@return boolean changed
function M.close(tabpage, bufnr)
  tabpage, bufnr = resolve_tab(tabpage), resolve_buf(bufnr)
  if not M.contains(tabpage, bufnr) then
    return false
  end
  local shared = false
  for tab, state in pairs(tabs) do
    if tab ~= tabpage and valid_tab(tab) and state.members[bufnr] then
      shared = true
      break
    end
  end
  if not shared and vim.bo[bufnr].modified then
    vim.notify(
      'Buffer has unsaved changes; save it or use :bdelete! to discard them',
      'warn'
    )
    return false
  end
  local replacement
  for _, buf in ipairs(M.list(tabpage)) do
    if buf ~= bufnr then
      replacement = buf
      break
    end
  end
  M.pause()
  local ok, err = pcall(function()
    for _, win in ipairs(api.nvim_tabpage_list_wins(tabpage)) do
      if api.nvim_win_get_buf(win) == bufnr then
        replacement = replacement or api.nvim_create_buf(true, false)
        api.nvim_win_set_buf(win, replacement)
      end
    end
    if not shared then
      api.nvim_buf_delete(bufnr, { force = false })
    end
    M.detach(tabpage, bufnr)
    if replacement then
      M.attach(tabpage, replacement)
    end
  end)
  M.resume()
  if not ok then
    error(err)
  end
  return true
end

---Replace one tab's ordered list, e.g. after session restoration.
---Duplicates and ineligible buffers are skipped. Other tabs are untouched.
---@param tabpage integer
---@param buffers integer[]
---@return boolean success
function M.replace(tabpage, buffers)
  tabpage = resolve_tab(tabpage)
  if not valid_tab(tabpage) then
    return false
  end
  local state = { buffers = {}, members = {} }
  for _, bufnr in ipairs(buffers) do
    if eligible(bufnr) and not state.members[bufnr] then
      state.buffers[#state.buffers + 1] = bufnr
      state.members[bufnr] = true
    end
  end
  tabs[tabpage] = state
  redraw()
  return true
end

---Suspend automatic attachment while saving/restoring sessions or previewing.
---Calls may be nested. Explicit edits and deletion cleanup still work.
function M.pause()
  pause_depth = pause_depth + 1
  tracking_generation = tracking_generation + 1
end

---Resume without scanning windows, so restored membership stays authoritative.
function M.resume()
  assert(pause_depth > 0, 'tab_buffers.resume() called without pause()')
  pause_depth = pause_depth - 1
end

local function track_window(win)
  local config = api.nvim_win_get_config(win)
  if config.relative ~= '' or config.external or vim.wo[win].previewwindow then
    return
  end
  M.attach(api.nvim_win_get_tabpage(win), api.nvim_win_get_buf(win))
end

local function scan(bufnr)
  if pause_depth > 0 then
    return
  end
  for _, tab in ipairs(api.nvim_list_tabpages()) do
    for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
      if not bufnr or api.nvim_win_get_buf(win) == bufnr then
        track_window(win)
      end
    end
  end
end

---Install tracking and seed existing ordinary windows. Safe to call again.
---Requiring the module alone has no side effects. Buffers hidden before setup
---cannot be assigned to a tab automatically; use attach/replace for those.
function M.setup()
  tracking_generation = tracking_generation + 1
  local group = api.nvim_create_augroup('nvim_tab_buffers', { clear = true })
  api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'BufAdd' }, {
    group = group,
    callback = function(event)
      -- BufWinEnter need not refer to the current window (e.g. win_set_buf).
      -- fzf-lua lists buffers after entering them; BufAdd catches that change.
      -- Scan visible windows only, so hidden additions/previews stay excluded.
      scan(event.buf)
    end,
  })
  api.nvim_create_autocmd('WinEnter', {
    group = group,
    callback = function()
      if pause_depth > 0 then
        return
      end
      local win = api.nvim_get_current_win()
      local buf = api.nvim_win_get_buf(win)
      local tab = api.nvim_win_get_tabpage(win)
      local state, generation = tabs[tab], tracking_generation
      -- :tabnew enters a temporary copy of the previous window before
      -- replacing its buffer. Do not inherit that buffer into the new tab.
      vim.schedule(function()
        if
          pause_depth == 0
          and generation == tracking_generation
          and tabs[tab] == state
          and api.nvim_win_is_valid(win)
          and api.nvim_win_get_buf(win) == buf
        then
          track_window(win)
        end
      end)
    end,
  })
  api.nvim_create_autocmd('TabEnter', {
    group = group,
    callback = redraw,
  })
  api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = group,
    callback = function(event)
      for tabpage in pairs(tabs) do
        M.detach(tabpage, event.buf)
      end
    end,
  })
  api.nvim_create_autocmd('TabClosed', {
    group = group,
    callback = function()
      -- TabClosed's match is a tab number, not a stable tabpage handle.
      for tabpage in pairs(tabs) do
        if not valid_tab(tabpage) then
          tabs[tabpage] = nil
        end
      end
      redraw()
    end,
  })
  scan()
end

return M
