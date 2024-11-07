if vim.g.enable_bueatify then
  return {
    -- lazy.nvim
    {
      'folke/noice.nvim',
      event = 'VeryLazy',
      opts = {
        -- add any options here
      },
      config = function()
        require('noice').setup {
          lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
              ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
              ['vim.lsp.util.stylize_markdown'] = true,
              ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
            },
          },
          -- you can enable a preset for easier configuration
          presets = {
            bottom_search = true, -- use a classic bottom cmdline for search
            command_palette = true, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = true, -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = true, -- add a border to hover docs and signature help
          },
          -- use a classic bottom cmdline for search
          cmdline = {
            format = {
              search_down = {
                view = 'cmdline',
              },
              search_up = {
                view = 'cmdline',
              },
            },
          },
          routes = {
            -- dismiss written messages
            {
              filter = {
                event = 'msg_show',
                kind = '',
                find = 'written',
              },
              opts = { skip = true },
            },
            -- dismiss lsp hover's no information available
            {
              filter = {
                find = 'No information available',
              },
              opts = { skip = true },
            },
          },
          -- display the cmdline and popupmenu together
          views = {
            cmdline_popup = {
              position = {
                row = 5,
                col = '50%',
              },
              size = {
                width = 60,
                height = 'auto',
              },
            },
            popupmenu = {
              relative = 'editor',
              position = {
                row = 8,
                col = '50%',
              },
              size = {
                width = 60,
                height = 10,
              },
              border = {
                style = 'rounded',
                padding = { 0, 1 },
              },
              win_options = {
                winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
              },
            },
          },
        }
      end,
      dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        'MunifTanjim/nui.nvim',
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        {
          'rcarriga/nvim-notify',
          keys = {
            {
              '<leader>un',
              function()
                require('notify').dismiss { silent = true, pending = true }
              end,
              desc = 'Dismiss All Notifications',
            },
          },
          config = function()
            local opts = {
              render = 'wrapped-compact',
              stages = 'slide',
              timeout = 5000,
            }
            vim.opt.termguicolors = true
            require('notify').setup(opts)
            vim.notify = require 'notify'
          end,
        },
      },
    },
  }
else
  return {}
end
