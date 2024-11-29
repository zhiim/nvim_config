local tab_tools = {
  barbar = {
    'romgrk/barbar.nvim',
    event = 'BufEnter',
    init = function()
      vim.g.barbar_auto_setup = false
      -- barbar
      vim.keymap.set('n', '<tab>', '<cmd>BufferNext<CR>', { desc = 'buffer goto next' })
      vim.keymap.set('n', '<S-tab>', '<cmd>BufferPrevious<CR>', { desc = 'buffer goto previous' })
      vim.keymap.set('n', '<leader>x', '<cmd>BufferClose<CR>', { desc = 'buffer close', noremap = true, silent = true })
      vim.keymap.set('n', '<A-,>', '<cmd>BufferMovePrevious<CR>', { desc = 'buffer move previous' })
      vim.keymap.set('n', '<A-.>', '<cmd>BufferMoveNext<CR>', { desc = 'buffer move next' })
      for i = 1, 9 do
        vim.keymap.set('n', '<A-' .. i .. '>', '<cmd>BufferGoto ' .. i .. '<CR>', { desc = 'buffer goto ' .. i })
      end
      if vim.g.options.enhance then
        vim.keymap.set('n', '<leader>x', function()
          Snacks.bufdelete()
        end, { desc = 'buffer close' })
      end
    end,
    opts = {
      auto_hide = 1,
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    cmd = { 'BufferNext', 'BufferPrevious', 'BufferClose' },
  },

  bufferline = {
    'akinsho/bufferline.nvim',
    event = 'BufReadPre',
    config = function()
      vim.opt.termguicolors = true
      local explorer_type = {
        nvimtree = 'NvimTree',
        neotree = 'neo-tree',
      }
      require('bufferline').setup {
        options = {
          numbers = 'ordinal', -- show buffer numbers
          separator_style = 'slant', -- style of buffer separator
          diagnostics = 'nvim_lsp', -- show diagnostics
          -- snippet used to customize the diagnostics indicator
          diagnostics_indicator = function(_, _, diagnostics_dict)
            local s = ' '
            for e, n in pairs(diagnostics_dict) do
              local sym = e == 'error' and ' ' or (e == 'warning' and ' ' or ' ')
              s = s .. n .. sym
            end
            return s
          end,
          -- a unique tab for file explorer
          offsets = {
            {
              filetype = explorer_type[vim.g.options.file_explorer],
              text = 'File Explorer',
              text_align = 'center',
              separator = false,
              highlight = 'Directory',
            },
          },
          always_show_bufferline = false,
          custom_filter = function(buf, _)
            -- dont show help buffers in the bufferline
            return not require('utils.util').find_value(vim.bo[buf].filetype, { 'dap-repl', 'codecompanion' })
          end,
        },
      }
      vim.keymap.set('n', '<tab>', '<cmd>BufferLineCycleNext<CR>', { desc = 'buffer goto next' })
      vim.keymap.set('n', '<S-tab>', '<cmd>BufferLineCyclePrev<CR>', { desc = 'buffer goto previous' })
      vim.keymap.set('n', '<leader>x', '<cmd> bp|sp|bn|bd! <CR>', { desc = 'buffer close', noremap = true, silent = true })
      vim.keymap.set('n', '<A-,>', '<cmd>BufferLineMovePrev<CR>', { desc = 'buffer move previous' })
      vim.keymap.set('n', '<A-.>', '<cmd>BufferLineMoveNext<CR>', { desc = 'buffer move next' })
      for i = 1, 9 do
        vim.keymap.set('n', '<A-' .. i .. '>', function()
          require('bufferline').go_to(i, true)
        end, { desc = 'buffer goto ' .. i })
      end
      if vim.g.options.enhance then
        vim.keymap.set('n', '<leader>x', function()
          Snacks.bufdelete()
        end, { desc = 'buffer close' })
      end
    end,
  },

  tabby = {
    'nanozuki/tabby.nvim',
    event = 'BufReadPre',
    config = function()
      -- always show tabline
      vim.o.showtabline = 2

      vim.keymap.set('n', '<tab>', '<cmd>bnext<CR>', { desc = 'buffer goto next' })
      vim.keymap.set('n', '<S-tab>', '<cmd>bpre<CR>', { desc = 'buffer goto previous' })
      if vim.g.options.enhance then
        vim.keymap.set('n', '<leader>x', function()
          Snacks.bufdelete()
        end, { desc = 'buffer close' })
      else
        vim.keymap.set('n', '<leader>x', '<cmd> bp|sp|bn|bd! <CR>', { desc = 'buffer close', noremap = true, silent = true })
      end

      local theme = {}
      local ok, ll_theme = pcall(require, 'lualine.themes.auto')
      if ok then
        theme = {
          fill = ll_theme.normal.c,
          head = ll_theme.normal.b,
          current_tab = ll_theme.normal.a,
          tab = ll_theme.normal.b,
          current_buf = ll_theme.normal.a,
          buf = ll_theme.normal.b,
          tail = ll_theme.normal.b,
        }
      end

      require('tabby').setup {
        line = function(line)
          return {
            {
              { '  ', hl = theme.head },
              line.sep('', theme.head, theme.fill),
            },

            line.tabs().foreach(function(tab)
              local hl = tab.is_current() and theme.current_tab or theme.tab
              return {
                line.sep('', hl, theme.fill),
                tab.number(),
                tab.name(),
                tab.close_btn '', -- show a close button
                line.sep('', hl, theme.fill),
                hl = hl,
                margin = ' ',
              }
            end),

            line.spacer(),

            line.bufs().foreach(function(buf)
              local hl = buf.is_current() and theme.current_buf or theme.buf
              return {
                line.sep('', hl, theme.fill),
                buf.is_changed() and '+' or '',
                buf.file_icon(),
                buf.name(),
                line.sep('', hl, theme.fill),
                hl = hl,
                margin = ' ',
              }
            end),

            {
              line.sep('', theme.tail, theme.fill),
              { '  ', hl = theme.tail },
            },
            hl = theme.fill,
          }
        end,
        option = {
          lualine_theme = 'auto',
          buf_name = {
            mode = 'tail',
          },
        },
      }
    end,
  },
}
return tab_tools[vim.g.options.tab]
