local M = {}
local tab_buffers = require 'utils.tab_buffers'

local function current_filter()
  local tab = vim.api.nvim_get_current_tabpage()
  return function(buf)
    return tab_buffers.contains(tab, buf)
  end
end

function M.telescope_buffers()
  local filter = current_filter()
  local max_bufnr = 0
  for _, buf in ipairs(tab_buffers.list()) do
    max_bufnr = math.max(max_bufnr, buf)
  end
  local opts = {
    prompt_title = 'Tab Buffers',
    bufnr_width = #tostring(max_bufnr),
  }
  local make_entry = require('telescope.make_entry').gen_from_buffer(opts)
  -- Telescope's builtin buffers picker has no buffer-filter option. Returning
  -- nil from its public entry_maker skips entries, retaining builtin actions.
  opts.entry_maker = function(entry)
    if filter(entry.bufnr) then
      return make_entry(entry)
    end
  end
  require('telescope.builtin').buffers(opts)
end

function M.telescope_live_grep()
  local files = {}
  for _, buf in ipairs(tab_buffers.list()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= '' and vim.fn.filereadable(name) == 1 then
      files[#files + 1] = name
    end
  end
  if #files == 0 then
    -- An empty search_dirs list would search the whole project instead.
    vim.notify('No files to search in this tab', vim.log.levels.INFO)
    return
  end
  require('telescope.builtin').live_grep {
    search_dirs = files,
    prompt_title = 'Live Grep in Tab Buffers',
  }
end

function M.fzf_buffers()
  require('fzf-lua').buffers { filter = current_filter() }
end

function M.fzf_lines()
  require('fzf-lua').lines { filter = current_filter() }
end

return M
