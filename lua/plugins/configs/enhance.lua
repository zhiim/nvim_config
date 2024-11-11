if vim.g.enable_enhance then
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
          cmdline = {
            view = 'cmdline',
          },
          lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
              ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
              ['vim.lsp.util.stylize_markdown'] = true,
              ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
            },
            signature = {
              enabled = true, -- used lsp_signature instead
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
          messages = {
            view = 'mini', -- use mini view for commom messages
          },
          format = {
            lsp_progress_done = {
              { '󰸞 ', hl_group = 'NoiceLspProgressSpinner' },
              { '{data.progress.title} ', hl_group = 'NoiceLspProgressTitle' },
              { '{data.progress.client} ', hl_group = 'NoiceLspProgressClient' },
            },
          },
          routes = {
            -- dismiss written messages
            -- dismiss lsp hover's no information available
            {
              filter = {
                event = 'notify',
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
            mini = {
              align = 'message-center',
              position = {
                row = -1, -- bottom
                col = '50%', -- center
              },
              border = {
                style = 'rounded',
              },
              size = {
                width = 'auto',
                height = 'auto',
              },
            },
          },
        }
        require('lualine').setup {
          sections = {
            lualine_x = {
              {
                require('noice').api.status.message.get_hl,
                cond = require('noice').api.status.message.has,
              },
              {
                require('noice').api.status.search.get,
                cond = require('noice').api.status.search.has,
                color = { fg = require('utils.palette').get_palette().orange },
              },
              'encoding',
              'fileformat',
              'filetype',
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
