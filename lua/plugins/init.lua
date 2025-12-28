require('lazy').setup({

  { 'tpope/vim-sleuth', event = 'BufRead' }, -- Detect tabstop and shiftwidth automatically

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Local Keymaps (which-key)',
      },
    },
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup {
        preset = 'helix',
      }
      if vim.g.options.mode == 'IDE' then
        require('which-key').add {
          {
            '<leader>c',
            group = 'CodeCompanion, CommentBox',
            mode = { 'n', 'v' },
          },
          { '<leader>cc', group = 'CodeCompanion', mode = { 'n', 'v' } },
          { '<leader>cb', group = 'CommentBox', mode = { 'n', 'v' } },
          { '<leader>d', group = 'Dropbar, DiffView' },
          { '<leader>dv', group = 'DiffView' },
          { '<leader>dt', group = 'DapView toggle' },
          { '<leader>g', group = 'Glance, GrugFar' },
          { '<leader>gp', group = 'Grapple' },
          { '<leader>l', group = 'LSP' },
          { '<leader>m', group = 'Mini' },
          { '<leader>mm', group = 'Mini.map' },
          { '<leader>n', group = 'Snacks' },
          { '<leader>nn', group = 'Snacks.notification' },
          { '<leader>nt', group = 'Snacks.toggle' },
          { '<leader>ns', group = 'Snacks.scratch' },
          { '<leader>p', group = 'Portal, Preview image' },
          { '<leader>r', group = 'Rename, ReSessison' },
          { '<leader>rs', group = 'ReSessison' },
          { '<leader>s', group = 'Picker' },
          { '<leader>t', group = 'Trouble' },
          { '<leader>u', group = 'Utils' },
          { '<leader>uo', group = 'Utils.options' },
        }
      end
    end,
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    enabled = vim.g.options.mode ~= 'IDE',
    event = 'BufRead',
    main = 'ibl',
    opts = {},
    config = function()
      require('ibl').setup {
        indent = {
          highlight = {
            'ForeRed',
            'ForeYellow',
            'ForeBlue',
            'ForeOrange',
            'ForeGreen',
            'ForePurple',
            'ForeCyan',
          },
          char = '▏',
        },
        exclude = {
          filetypes = { 'dashboard' },
        },
      }
    end,
  },

  {
    'max397574/better-escape.nvim',
    event = 'BufRead',
    config = function()
      require('better_escape').setup {
        default_mappings = false,
        mappings = {
          i = {
            j = {
              j = '<Esc>',
              k = '<Esc>',
            },
          },
          t = {
            j = {
              k = '<C-\\><C-n>',
            },
          },
        },
      }
    end,
  },

  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    keys = {
      --smart-split
      {
        '<C-h>',
        function()
          require('smart-splits').move_cursor_left()
        end,
        mode = 'n',
        desc = 'Move Left',
      },
      {
        '<C-l>',
        function()
          require('smart-splits').move_cursor_right()
        end,
        mode = 'n',
        desc = 'Move Right',
      },
      {
        '<C-j>',
        function()
          require('smart-splits').move_cursor_down()
        end,
        mode = 'n',
        desc = 'Move Down',
      },
      {
        '<C-k>',
        function()
          require('smart-splits').move_cursor_up()
        end,
        mode = 'n',
        desc = 'Move Up',
      },
      {
        '<C-A-h>',
        function()
          require('smart-splits').swap_buf_left()
        end,
        mode = 'n',
        desc = 'Move Left',
      },
      {
        '<C-A-l>',
        function()
          require('smart-splits').swap_buf_right()
        end,
        mode = 'n',
        desc = 'Move Right',
      },
      {
        '<C-A-j>',
        function()
          require('smart-splits').swap_buf_down()
        end,
        mode = 'n',
        desc = 'Move Down',
      },
      {
        '<C-A-k>',
        function()
          require('smart-splits').swap_buf_up()
        end,
        mode = 'n',
        desc = 'Move Up',
      },
      {
        '<A-h>',
        function()
          require('smart-splits').resize_left()
        end,
        mode = 'n',
        desc = 'Resize Left',
      },
      {
        '<A-l>',
        function()
          require('smart-splits').resize_right()
        end,
        mode = 'n',
        desc = 'Resize Right',
      },
      {
        '<A-j>',
        function()
          require('smart-splits').resize_down()
        end,
        mode = 'n',
        desc = 'Resize Down',
      },
      {
        '<A-k>',
        function()
          require('smart-splits').resize_up()
        end,
        mode = 'n',
        desc = 'Resize Up',
      },
      {
        '<A-H>',
        function()
          require('smart-splits').swap_buf_left()
        end,
        mode = 'n',
        desc = 'Swap Left',
      },
      {
        '<A-L>',
        function()
          require('smart-splits').swap_buf_right()
        end,
        mode = 'n',
        desc = 'Swap Right',
      },
      {
        '<A-J>',
        function()
          require('smart-splits').swap_buf_down()
        end,
        mode = 'n',
        desc = 'Swap Down',
      },
      {
        '<A-K>',
        function()
          require('smart-splits').swap_buf_up()
        end,
        mode = 'n',
        desc = 'Swap Up',
      },
    },
    config = function()
      require('smart-splits').setup {}
    end,
  },

  {
    'echasnovski/mini.icons',
    lazy = true,
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },

  require 'plugins.configs.ui',
  require 'plugins.configs.language',
  require 'plugins.configs.git',
  require 'plugins.configs.util',
  require 'plugins.configs.extras',
  require 'plugins.configs.picker',
  require 'plugins.configs.explorer',
  require 'plugins.configs.tab',
  require 'plugins.configs.term',
  require 'plugins.configs.session',
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
