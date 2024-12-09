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
      if vim.g.options.enhance then
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
            -- dont show help buffers in the bufferline
            return not require('utils.util').find_value(
              vim.bo[buf].filetype,
              { 'dap-repl', 'codecompanion' }
            )
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
      -- for i = 1, 9 do
      --   vim.keymap.set('n', '<A-' .. i .. '>', function()
      --     require('bufferline').go_to(i, true)
      --   end, { desc = 'Buffer goto ' .. i })
      -- end
      if vim.g.options.enhance then
        vim.keymap.set('n', '<leader>x', function()
          Snacks.bufdelete()
        end, { desc = 'Buffer close' })
      else
        vim.keymap.set(
          'n',
          '<leader>x',
          '<cmd> bp|sp|bn|bd! <CR>',
          { desc = 'Buffer close', noremap = true, silent = true }
        )
      end
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

      vim.keymap.set(
        'n',
        '<tab>',
        '<cmd>bnext<CR>',
        { desc = 'Buffer goto next' }
      )
      vim.keymap.set(
        'n',
        '<S-tab>',
        '<cmd>bpre<CR>',
        { desc = 'Buffer goto previous' }
      )
      if vim.g.options.enhance then
        vim.keymap.set('n', '<leader>x', function()
          Snacks.bufdelete()
        end, { desc = 'Buffer close' })
      else
        vim.keymap.set(
          'n',
          '<leader>x',
          '<cmd> bp|sp|bn|bd! <CR>',
          { desc = 'Buffer close', noremap = true, silent = true }
        )
      end

      local theme = {}
      local ok, ll_theme = pcall(require, 'lualine.themes.auto')
      if ok then
        theme = {
          fill = ll_theme.normal.c,
          head = ll_theme.normal.b,
          current_tab = vim.list_extend(ll_theme.normal.a, { style = 'bold' }),
          tab = vim.list_extend(ll_theme.normal.b, { style = 'bold' }),
          current_buf = ll_theme.normal.a,
          buf = ll_theme.normal.b,
          tail = ll_theme.normal.b,
        }
      else
        theme = {
          fill = 'TabLineFill',
          head = 'TabLine',
          current_tab = 'TabLineSel',
          tab = 'TabLine',
          current_buf = 'TabLineSel',
          buf = 'TabLine',
          tail = 'TabLine',
        }
      end

      local function lsp_diag(bufnr)
        local icons = {
          error = ' ',
          warn = ' ',
          info = ' ',
          hint = ' ',
        }
        local label = ''
        for severity, icon in pairs(icons) do
          local n = #vim.diagnostic.get(
            bufnr,
            { severity = vim.diagnostic.severity[string.upper(severity)] }
          )
          if n > 0 then
            label = label .. ' ' .. icon .. n
          end
        end
        return label
      end

      require('tabby').setup {
        line = function(line)
          if vim.fn.tabpagenr '$' > 1 then
            -- if there are multiple tabs, work as the tabline, with wins
            return {
              {
                { '  ', hl = theme.head },
                line.sep('', theme.head, theme.fill),
              },

              line.bufs().foreach(function(buf)
                if
                  require('utils.util').find_value(
                    vim.bo[buf.id].filetype,
                    { 'dap-repl', 'codecompanion' }
                  )
                then
                  return {}
                end
                local hl = buf.is_current() and theme.current_buf or theme.buf
                return {
                  line.sep('', hl, theme.fill),
                  buf.is_changed() and '[+]' or '',
                  buf.file_icon(),
                  buf.name(),
                  lsp_diag(buf.id),
                  line.sep('', hl, theme.fill),
                  hl = hl,
                  margin = ' ',
                }
              end),

              line.spacer(),

              line.tabs().foreach(function(tab)
                local hl = tab.is_current() and theme.current_tab or theme.tab
                return {
                  line.sep('', hl, theme.fill),
                  tab.number(),
                  line.sep('', hl, theme.fill),
                  hl = hl,
                  margin = ' ',
                }
              end),

              hl = theme.fill,
            }
          else
            -- if there is only one tab, work as the bufferline
            return {
              {
                { '  ', hl = theme.head },
                line.sep('', theme.head, theme.fill),
              },

              line.bufs().foreach(function(buf)
                if
                  require('utils.util').find_value(
                    vim.bo[buf.id].filetype,
                    { 'dap-repl', 'codecompanion' }
                  )
                then
                  return {}
                end
                local hl = buf.is_current() and theme.current_buf or theme.buf
                return {
                  line.sep('', hl, theme.fill),
                  buf.is_changed() and '[+]' or '',
                  buf.file_icon(),
                  buf.name(),
                  lsp_diag(buf.id),
                  line.sep('', hl, theme.fill),
                  hl = hl,
                  margin = ' ',
                }
              end),

              line.spacer(),

              hl = theme.fill,
            }
          end
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
return {
  tab_tools[vim.g.options.tab],
  {
    'tiagovla/scope.nvim',
    config = function()
      vim.opt.sessionoptions = { -- required
        'buffers',
        'tabpages',
        'globals',
      }
      require('scope').setup {}
    end,
  },
}
