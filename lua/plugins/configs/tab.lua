local tab_tools = {
  barbar = {
    'romgrk/barbar.nvim',
    event = 'BufEnter',
    init = function()
      vim.g.barbar_auto_setup = false
      -- barbar
      vim.keymap.set(
        'n',
        '<tab>',
        '<cmd>BufferNext<CR>',
        { desc = 'Buffer goto next' }
      )
      vim.keymap.set(
        'n',
        '<S-tab>',
        '<cmd>BufferPrevious<CR>',
        { desc = 'Buffer goto previous' }
      )
      vim.keymap.set(
        'n',
        '<A-,>',
        '<cmd>BufferMovePrevious<CR>',
        { desc = 'Buffer move previous' }
      )
      vim.keymap.set(
        'n',
        '<A-.>',
        '<cmd>BufferMoveNext<CR>',
        { desc = 'Buffer move next' }
      )
      for i = 1, 9 do
        vim.keymap.set(
          'n',
          '<A-' .. i .. '>',
          '<cmd>BufferGoto ' .. i .. '<CR>',
          { desc = 'buffer goto ' .. i }
        )
      end
      if
        vim.g.options.mode.chosen == 2
        and (
          vim.g.options.plugins.util.enable_all
          or vim.g.options.plugins.util.components.snacks
        )
      then
        vim.keymap.set('n', '<leader>x', function()
          Snacks.bufdelete()
        end, { desc = 'buffer close' })
      else
        vim.keymap.set(
          'n',
          '<leader>x',
          '<cmd>BufferClose<CR>',
          { desc = 'Buffer close', noremap = true, silent = true }
        )
      end
    end,
    opts = {
      animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    cmd = { 'BufferNext', 'BufferPrevious', 'BufferClose' },
  },

  bufferline = {
    'akinsho/bufferline.nvim',
    event = 'BufReadPre',
    init = function()
      require('utils.tab_buffers').setup()
    end,
    config = function()
      vim.opt.termguicolors = true
      local explorer_type = {
        nvimtree = 'NvimTree',
        neotree = 'neo-tree',
      }
      require('bufferline').setup {
        options = {
          numbers = 'ordinal', -- show buffer numbers
          max_name_length = 16,
          tab_size = 16,
          separator_style = 'thin', -- style of buffer separator
          diagnostics = 'nvim_lsp', -- show diagnostics
          -- snippet used to customize the diagnostics indicator
          diagnostics_indicator = function(_, _, diagnostics_dict)
            local s = ' '
            for e, n in pairs(diagnostics_dict) do
              local sym = e == 'error' and ' '
                or (e == 'warning' and ' ' or ' ')
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
          custom_filter = function(buf, _)
            return require('utils.tab_buffers').contains(nil, buf)
              and not require('utils.util').find_value(
                vim.bo[buf].filetype,
                { 'dap-repl', 'codecompanion' }
              )
          end,
          close_command = function(buf)
            require('utils.tab_buffers').close(nil, buf)
          end,
          right_mouse_command = function(buf)
            require('utils.tab_buffers').close(nil, buf)
          end,
        },
      }
      vim.keymap.set(
        'n',
        '<tab>',
        '<cmd>BufferLineCycleNext<CR>',
        { desc = 'Buffer goto next' }
      )
      vim.keymap.set(
        'n',
        '<S-tab>',
        '<cmd>BufferLineCyclePrev<CR>',
        { desc = 'Buffer goto previous' }
      )
      vim.keymap.set(
        'n',
        '<A-,>',
        '<cmd>BufferLineMovePrev<CR>',
        { desc = 'Buffer move previous' }
      )
      vim.keymap.set(
        'n',
        '<A-.>',
        '<cmd>BufferLineMoveNext<CR>',
        { desc = 'Buffer move next' }
      )
      for i = 1, 9 do
        vim.keymap.set('n', '<A-' .. i .. '>', function()
          require('bufferline').go_to(i, true)
        end, { desc = 'buffer goto ' .. i })
      end
      vim.keymap.set('n', '<leader>x', function()
        require('utils.tab_buffers').close()
      end, { desc = 'Buffer close in current tab' })
    end,
  },

  tabby = {
    'nanozuki/tabby.nvim',
    event = 'BufReadPre',
    config = function()
      vim.opt.sessionoptions =
        'curdir,folds,globals,help,tabpages,terminal,winsize'
      -- always show tabline
      vim.o.showtabline = 2

      local theme = {}
      local ok, ll_theme = pcall(require, 'lualine.themes.auto')
      if ok then
        theme = {
          fill = ll_theme.normal.c,
          head = ll_theme.normal.b,
          current_tab = vim.list_extend(ll_theme.normal.a, { style = 'bold' }),
          tab = vim.list_extend(ll_theme.normal.b, { style = 'bold' }),
        }
      else
        theme = {
          fill = 'TabLineFill',
          head = 'TabLine',
          current_tab = 'TabLineSel',
          tab = 'TabLine',
        }
      end

      -- any buffer have unsaved changes
      local function tab_is_modified(tab)
        for _, win in ipairs(tab.wins().wins) do
          if win.buf().is_changed() then
            return true
          end
        end
      end

      require('tabby').setup {
        line = function(line)
          return {
            {
              { '  ', hl = theme.head },
              line.sep('', theme.head, theme.fill),
            },
            line.tabs().foreach(function(tab)
              local name = tab.name()
              local index = string.find(name, '%[%d')
              local tab_name = index and string.sub(name, 1, index - 1) or name

              local hl = tab.is_current() and theme.current_tab or theme.tab
              return {
                line.sep('', hl, theme.fill),
                tab.is_current() and '' or '',
                tab.number() .. '#',
                tab_name,
                tab_is_modified(tab) and '*' or '',
                line.sep('', hl, theme.fill),
                hl = hl,
                margin = ' ',
              }
            end),
            hl = theme.fill,
          }
        end,
        option = {
          buf_name = {
            mode = 'unique',
          },
        },
      }
    end,
  },
}

local tab = vim.g.options.tab
return tab_tools[tab.choices[tab.chosen]]
