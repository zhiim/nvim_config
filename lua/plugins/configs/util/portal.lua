local util_opts = vim.g.options.plugins.util

-- Show four portal previews at a time without limiting the underlying search to four results.
local function portal_wrapper(name)
  local portal = require 'portal'
  local settings = require 'portal.settings'
  local results = require('portal.builtin')[name].search {
    max_results = settings.lookback,
  }
  if #results == 0 then
    vim.notify 'Portal: empty search results'
    return
  end

  local anchor_win = vim.api.nvim_get_current_win()
  local height = settings.window_options.height
  local step = height + 2 -- Borders occupy one row above and below each preview.
  local win_height = vim.api.nvim_win_get_height(anchor_win)
  local win_width = vim.api.nvim_win_get_width(anchor_win)
  local page_size = math.min(#settings.labels, math.floor(win_height / step))
  if page_size < 1 or win_width < 3 then
    vim.notify(
      'Portal: not enough window space for a preview',
      vim.log.levels.WARN
    )
    return
  end
  local total_pages = math.ceil(#results / page_size)
  local page = 1
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)

  while true do
    local first = (page - 1) * page_size + 1
    local page_results = {}
    for i = first, math.min(first + page_size - 1, #results) do
      page_results[#page_results + 1] = results[i]
    end
    local windows = portal.portals(page_results)
    portal.open(windows)
    vim.api.nvim_echo({
      {
        ('Portal %d/%d'):format(page, total_pages),
      },
    }, false, {})

    local selected
    local next_page = page
    while true do
      local ok, key = pcall(vim.fn.getcharstr)
      if not ok or key == 'q' or key == esc then
        break
      elseif key == ']' and page < total_pages then
        next_page = page + 1
        break
      elseif key == '[' and page > 1 then
        next_page = page - 1
        break
      end
      for _, window in ipairs(windows) do
        if window:has_label(key) then
          selected = window.content
          break
        end
      end
      if selected then
        break
      end
    end

    portal.close(windows)
    vim.api.nvim_echo({ { '' } }, false, {})
    if selected then
      selected:select()
      return
    end
    if next_page == page then
      return
    end
    page = next_page
  end
end

return {
  'cbochs/portal.nvim',
  enabled = vim.fn.has 'nvim-0.8' and util_opts.components.portal
    or util_opts.enable_all,
  keys = {
    {
      '<leader>pj',
      function()
        portal_wrapper 'jumplist'
      end,
      mode = 'n',
      desc = 'Portal jumplist',
    },
    {
      '<leader>pc',
      function()
        portal_wrapper 'changelist'
      end,
      mode = 'n',
      desc = 'Portal changelist',
    },
    {
      '<leader>pg',
      function()
        portal_wrapper 'grapple'
      end,
      mode = 'n',
      desc = 'Portal grapple',
    },
  },
  config = function()
    require('portal').setup {
      escape = {
        ['q'] = true,
      },
      window_options = {
        border = 'rounded',
        height = 5,
      },
    }
  end,
}
