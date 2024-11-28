if vim.g.options.enhance then
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
      'Bekaboo/dropbar.nvim',
      event = 'BufEnter',
      keys = {
        {
          '<leader>db',
          function()
            require('dropbar.api').pick()
          end,
          mode = 'n',
          desc = 'Dropbar Pick',
        },
      },
      config = function()
        local utils = require 'dropbar.utils'
        require('dropbar').setup {
          bar = {
            -- when to attach the bar
            enable = function(buf, win, _)
              return vim.api.nvim_buf_is_valid(buf)
                and vim.api.nvim_win_is_valid(win)
                and vim.wo[win].winbar == ''
                and vim.fn.win_gettype(win) == ''
                -- do not attach to certain filetypes
                and not require('utils.util').find_value(vim.bo[buf].ft, { 'help', 'copilot-chat', 'codecompanion' })
                and ((pcall(vim.treesitter.get_parser, buf)) and true or false)
            end,
          },
          menu = {
            keymaps = {
              -- go to upper menu
              ['<Esc>'] = '<C-w>q',
              ['q'] = '<C-w>q',
              ['h'] = '<C-w>q',
              -- go to deeper menu
              ['l'] = function()
                local menu = utils.menu.get_current()
                if not menu then
                  return
                end
                local cursor = vim.api.nvim_win_get_cursor(menu.win)
                local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
                if component then
                  menu:click_on(component, nil, 1, 'l')
                end
              end,
              -- move to the selected item
              ['<CR>'] = function()
                local menu = utils.menu.get_current()
                if not menu then
                  return
                end
                local mouse = vim.fn.getmousepos()
                local clicked_menu = utils.menu.get { win = mouse.winid }
                -- If clicked on a menu, invoke the corresponding click action,
                -- else close all menus and set the cursor to the clicked window
                if clicked_menu then
                  clicked_menu:click_at({ mouse.line, mouse.column - 1 }, nil, 1, 'l')
                  return
                end
                utils.menu.exec 'close'
                utils.bar.exec 'update_current_context_hl'
                if vim.api.nvim_win_is_valid(mouse.winid) then
                  vim.api.nvim_set_current_win(mouse.winid)
                end
              end,
              -- fuzzy find
              ['i'] = function()
                local menu = utils.menu.get_current()
                if not menu then
                  return
                end
                menu:fuzzy_find_open()
              end,
            },
            win_configs = {
              border = 'rounded',
              style = 'minimal',
            },
          },
        }
      end,
    },

    {
      'rachartier/tiny-inline-diagnostic.nvim',
      event = function()
        if vim.fn.has 'nvim-0.10' then
          return 'LspAttach'
        else
          return 'VeryLazy'
        end
      end,
      priority = 1000, -- needs to be loaded in first
      config = function()
        -- diable default diagnostic virtual text
        vim.diagnostic.config { virtual_text = false }
        -- Default configuration
        require('tiny-inline-diagnostic').setup {
          signs = {
            left = '',
            right = '',
            diag = '●',
            arrow = '  ',
            up_arrow = '  ',
            vertical = ' │',
            vertical_end = ' └',
          },
          options = {
            -- Show the source of the diagnostic.
            show_source = true,
            -- If multiple diagnostics are under the cursor, display all of them.
            multiple_diag_under_cursor = true,
            -- Enable diagnostic message on all lines.
            multilines = true,
            -- Show all diagnostics on the cursor line.
            show_all_diags_on_cursorline = true,
            -- Enable diagnostics on Insert mode. You should also se the `throttle` option to 0, as some artefacts may appear.
            enable_on_insert = false,
          },
        }
      end,
    },
  }
else
  return {}
end
