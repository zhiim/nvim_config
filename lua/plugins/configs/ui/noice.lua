return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  enabled = vim.g.options.enhance,
  opts = {
    -- add any options here
  },
  config = function()
    local cmd_row = math.floor(vim.api.nvim_list_uis()[1].height) * 0.3
    require('noice').setup {
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
        command_palette = {
          views = {
            cmdline_popup = {
              position = {
                row = cmd_row,
                col = '50%',
              },
              size = {
                min_width = 60,
                width = 'auto',
                height = 'auto',
              },
            },
            cmdline_popupmenu = {
              relative = 'editor',
              position = {
                row = cmd_row + 3,
                col = '50%',
              },
              size = {
                width = 60,
                height = 'auto',
                max_height = 15,
              },
              border = {
                style = 'rounded',
                padding = { 0, 1 },
              },
              win_options = {
                winhighlight = {
                  Normal = 'Normal',
                  FloatBorder = 'NoiceCmdlinePopupBorder',
                },
              },
            },
          },
        }, -- position the cmdline and popupmenu together
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
    local fg_colors = require('utils.util').get_palette()
    require('lualine').setup {
      sections = {
        lualine_x = {
          ---@diagnostic disable: undefined-field
          {
            require('noice').api.status.command.get,
            cond = require('noice').api.status.command.has,
            color = { fg = fg_colors.blue },
          },
          {
            require('noice').api.status.mode.get,
            cond = require('noice').api.status.mode.has,
            color = { fg = fg_colors.magenta },
          },
          {
            require('noice').api.status.search.get,
            cond = require('noice').api.status.search.has,
            color = { fg = fg_colors.orange },
          },
          'encoding',
          'fileformat',
          'filetype',
        },
      },
    }
    require('telescope').load_extension 'noice'
    vim.keymap.set(
      'n',
      '<leader>sn',
      '<cmd>Telescope noice<cr>',
      { desc = 'Telescope search noice' }
    )
  end,
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    {
      'rcarriga/nvim-notify',
      config = function()
        local opts = {
          stages = 'slide',
        }
        vim.opt.termguicolors = true
        require('notify').setup(opts)
        vim.notify = require 'notify'
      end,
    },
  },
}
