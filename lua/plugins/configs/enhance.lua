if vim.g.options.enable_enhance then
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
              enabled = false, -- used lsp_signature instead
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
          views = {
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
                color = { fg = require('utils.util').get_palette().orange },
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
              render = 'default',
              stages = 'slide',
            }
            vim.opt.termguicolors = true
            require('notify').setup(opts)
            vim.notify = require 'notify'
          end,
        },
      },
    },

    -- animation
    {
      'echasnovski/mini.animate',
      event = 'VeryLazy',
      config = function()
        require('mini.animate').setup {
          scroll = {
            enable = false,
          },
          cursor = {
            enable = false,
          },
        }
      end,
    },

    {
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
    },
  }
else
  return {}
end
