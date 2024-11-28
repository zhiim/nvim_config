--- get git diff information using gitsigns
return {
  'nvim-lualine/lualine.nvim',
  config = function()
    -- custom filename component that highlights the filename based on its status
    local custom_fname = require('lualine.components.filename'):extend()
    local highlight = require 'lualine.highlight'

    local colors = require('utils.util').get_palette()
    local default_status_colors = { modified = colors.red }

    function custom_fname:init(options)
      custom_fname.super.init(self, options)
      self.status_colors = {
        saved = highlight.create_component_highlight_group({ fg = default_status_colors.saved }, 'filename_status_saved', self.options),
        modified = highlight.create_component_highlight_group({ fg = default_status_colors.modified }, 'filename_status_modified', self.options),
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
      options = {
        refresh = {
          statusline = 500,
          tabline = 500,
          winbar = 500,
        },
        component_separators = '|',
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          'dashboard',
          'snacks_dashboard',
        },
        ignore_focus = {
          'NvimTree',
          'neo-tree',
          'dapui_watches',
          'dapui_stacks',
          'dapui_scopes',
          'dapui_breakpoints',
          'dapui_console',
          'dap-repl',
          'trouble',
          'copilot-chat',
        },
        globalstatus = true,
      },
      sections = {
        lualine_b = {
          { 'branch' },
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
            source = function()
              local summary = vim.b.minidiff_summary
              return summary
                and {
                  added = summary.add,
                  modified = summary.change,
                  removed = summary.delete,
                }
            end,
          },
          {
            'diagnostics',
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
          },
        },
        lualine_c = {
          { custom_fname },
          {
            -- Lsp server name .
            function()
              local msg = 'No Active Lsp'
              local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
              local clients = vim.lsp.get_clients()
              if next(clients) == nil then
                return msg
              end
              local client_names = ''
              for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                  client_names = client_names .. client.name .. ' '
                end
              end
              return client_names
            end,
            icon = ' LSP:',
          },
        },
      },
    }
  end,
}
