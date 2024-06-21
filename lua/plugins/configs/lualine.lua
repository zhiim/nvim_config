--- get the current window number
---@return number
local function window()
  return vim.api.nvim_win_get_number(0)
end

--- get git diff information using gitsigns
local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'arkav/lualine-lsp-progress',
  },
  config = function()
    -- custom filename component that highlights the filename based on its status
    local custom_fname = require('lualine.components.filename'):extend()
    local highlight = require 'lualine.highlight'
    local colors = require('onedarkpro.helpers').get_colors()
    local default_status_colors = { saved = colors.grey, modified = colors.red }
    function custom_fname:init(options)
      custom_fname.super.init(self, options)
      self.status_colors = {
        saved = highlight.create_component_highlight_group({ bg = default_status_colors.saved }, 'filename_status_saved', self.options),
        modified = highlight.create_component_highlight_group({ bg = default_status_colors.modified }, 'filename_status_modified', self.options),
      }
      if self.options.color == nil then
        self.options.color = ''
      end
    end
    function custom_fname:update_status()
      local data = custom_fname.super.update_status(self)
      data = highlight.component_format_highlight(vim.bo.modified and self.status_colors.modified or self.status_colors.saved) .. data
      return data
    end

    require('lualine').setup {
      sections = {
        lualine_b = { { 'b:gitsigns_head', icon = '' }, { 'diff', source = diff_source }, 'diagnostics' },
        lualine_c = { window, custom_fname, 'lsp_progress' },
      },
    }
  end,
}
