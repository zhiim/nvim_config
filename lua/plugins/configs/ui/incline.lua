return {
  'b0o/incline.nvim',
  event = 'BufReadPre',
  config = function()
    local devicons = require 'nvim-web-devicons'

    require('incline').setup {
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
      },
      render = function(props)
        -- filename
        local filename =
          vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then
          filename = '[No Name]'
        end
        -- file icon and color
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified

        local function get_git_diff()
          local icons = { delete = ' ', change = ' ', add = ' ' }
          local signs = vim.b[props.buf].minidiff_summary

          local labels = {}
          if signs == nil then
            return labels
          end
          for name, icon in pairs(icons) do
            if tonumber(signs[name]) and signs[name] > 0 then
              table.insert(
                labels,
                { ' ', icon .. signs[name], group = 'MiniDiffSign' .. name }
              )
            end
          end
          if #labels > 0 then
            -- number of changed hunks
            table.insert(
              labels,
              1,
              { ' 󰊢 ' .. signs.n_ranges, group = 'GitHunks' }
            )
            table.insert(labels, 1, { ' |' })
            table.insert(labels, { ' ' })
          end
          return labels
        end

        local function get_diagnostic_label()
          local icons =
            { error = ' ', warn = ' ', info = ' ', hint = ' ' }
          local label = {}

          for severity, icon in pairs(icons) do
            local n = #vim.diagnostic.get(
              props.buf,
              { severity = vim.diagnostic.severity[string.upper(severity)] }
            )
            if n > 0 then
              table.insert(
                label,
                { ' ' .. icon .. n, group = 'DiagnosticSign' .. severity }
              )
            end
          end
          if #label > 0 then
            table.insert(label, 1, { ' |' })
          end
          return label
        end

        local get_hl = require('utils.util').get_hl
        local color_column_hl = get_hl('ColorColumn').bg
        local normal_hl = get_hl('Normal').bg
        return {
          ft_icon and {
            '',
            guifg = props.focused and ft_color or color_column_hl,
            guibg = normal_hl,
          } or '',

          ft_icon and {
            ft_icon,
            ' ',
            guibg = props.focused and ft_color or color_column_hl,
            guifg = props.focused and normal_hl or ft_color,
          } or '',

          { ' ', filename, gui = modified and 'italic' or 'bold' },
          { get_diagnostic_label() },
          { get_git_diff() },
          group = 'ColorColumn',
        }
      end,
    }
  end,
}
