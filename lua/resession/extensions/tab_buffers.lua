local M = {}
local api = vim.api
local tab_buffers = require 'utils.tab_buffers'
local installed = false
local loading

---Persist names in session tab order, never process-local buffer/tab handles.
function M.on_save(opts)
  local config = require 'resession.config'
  local tabpages = opts.tabpage and { opts.tabpage } or api.nvim_list_tabpages()
  local data = { version = 1, tabs = {} }
  for _, tab in ipairs(tabpages) do
    local names = {}
    for _, buf in ipairs(tab_buffers.list(tab)) do
      if config.buf_filter(buf) then
        names[#names + 1] = api.nvim_buf_get_name(buf)
      end
    end
    data.tabs[#data.tabs + 1] = names
  end
  return data
end

function M.on_pre_load()
  -- Resession has now closed the old layout or opened its destination tab.
  -- Restored tabs are inserted consecutively starting at this handle, even
  -- when loading into the middle of an existing set of tabs with reset=false.
  if loading then
    loading.first = api.nvim_get_current_tabpage()
  end
end

function M.on_post_load(data)
  assert(loading, 'tab_buffers session hooks are not installed')
  assert(
    data.version == 1 and type(data.tabs) == 'table',
    'Unsupported tab_buffers session data'
  )
  local tabpages = api.nvim_list_tabpages()
  local first
  for i, tab in ipairs(tabpages) do
    if tab == loading.first then
      first = i
      break
    end
  end
  assert(
    first and first + #data.tabs - 1 <= #tabpages,
    'Could not map restored tab_buffers tabs'
  )
  local by_name = {}
  for _, buf in ipairs(api.nvim_list_bufs()) do
    by_name[api.nvim_buf_get_name(buf)] = buf
  end
  for i, names in ipairs(data.tabs) do
    local buffers = {}
    for _, name in ipairs(names) do
      if by_name[name] then
        buffers[#buffers + 1] = by_name[name]
      end
    end
    tab_buffers.replace(tabpages[first + i - 1], buffers)
  end
  loading.restored = true
end

local function seed_visible(tab)
  tab_buffers.replace(tab, {})
  for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
    local config = api.nvim_win_get_config(win)
    if
      config.relative == ''
      and not config.external
      and not vim.wo[win].previewwindow
    then
      tab_buffers.attach(tab, api.nvim_win_get_buf(win))
    end
  end
end

---Install load hooks, including a visible-window fallback for older sessions.
function M.setup()
  if installed then
    return
  end
  installed = true
  local resession = require 'resession'
  resession.add_hook('pre_load', function()
    local current = api.nvim_get_current_tabpage()
    local buf = api.nvim_get_current_buf()
    local clean = #api.nvim_tabpage_list_wins(current) == 1
      and api.nvim_buf_get_name(buf) == ''
      and api.nvim_buf_line_count(buf) == 1
      and api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
    loading = { previous = {}, current = current, clean = clean }
    for _, tab in ipairs(api.nvim_list_tabpages()) do
      loading.previous[tab] = true
    end
    tab_buffers.pause()
  end)
  resession.add_hook('post_load', function(_, opts)
    local context = loading
    if not context then
      return
    end
    loading = nil
    local ok, err = pcall(function()
      if not context.restored then
        -- Legacy sessions did not record hidden-buffer membership. Infer
        -- only visible buffers, without changing tabs that were not loaded.
        for _, tab in ipairs(api.nvim_list_tabpages()) do
          if
            opts.reset
            or not context.previous[tab]
            or (context.clean and tab == context.current)
          then
            seed_visible(tab)
          end
        end
      end
    end)
    tab_buffers.resume()
    if not ok then
      error(err)
    end
  end)
end

return M
