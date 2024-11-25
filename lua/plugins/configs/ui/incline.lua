if vim.g.options.enhance then
  return {
    'b0o/incline.nvim',
    event = 'BufReadPre',
    dependencies = {
      {
        'SmiteshP/nvim-navic',
        config = function()
          require('nvim-navic').setup {
            lsp = {
              auto_attach = true,
            },
            highlight = true,
          }
        end,
      },
    },
    config = function()
      local helpers = require 'incline.helpers'
      local navic = require 'nvim-navic'
      local devicons = require 'nvim-web-devicons'

      require('incline').setup {
        window = {
          padding = 0,
          margin = { horizontal = 0, vertical = 0 },
        },
        render = function(props)
          -- filename
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
          if filename == '' then
            filename = '[No Name]'
          end
          -- file icon and color
          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          local res = {
            ft_icon and { ' ', ft_icon, ' ', guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or '',
            ' ',
            { filename, gui = modified and 'bold,italic' or 'bold' },
          }
          -- navic
          if props.focused then
            for _, item in ipairs(navic.get_data(props.buf) or {}) do
              table.insert(res, {
                { ' > ', group = 'NavicSeparator' },
                { item.icon, group = 'NavicIcons' .. item.type },
                { item.name, group = 'NavicText' },
              })
            end
            table.insert(res, ' ')
          end

          return res
        end,
      }
    end,
  }
else
  return {}
end
