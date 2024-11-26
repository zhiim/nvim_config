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
          separator_style = 'thick', -- style of buffer separator
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
}
return tab_tools[vim.g.options.tab]
