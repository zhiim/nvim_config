require('lazy').setup({

  { 'tpope/vim-sleuth', event = 'BufRead' }, -- Detect tabstop and shiftwidth automatically

  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    event = 'BufRead',
    opts = {},
  },

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
      require('which-key').setup {}
      require('which-key').add {
        {
          '<leader>c',
          group = 'Copilot, CodeCompanion, CommentBox',
          mode = { 'n', 'v' },
        },
        { '<leader>cc', group = 'CodeCompanion', mode = { 'n', 'v' } },
        { '<leader>cp', group = 'Copilot', mode = { 'n', 'v' } },
        { '<leader>cb', group = 'CommentBox', mode = { 'n', 'v' } },
        { '<leader>d', group = 'Dropbar and DiffView' },
        { '<leader>dv', group = 'DiffView' },
        { '<leader>f', group = 'Flashs', mode = { 'n', 'v' } },
        { '<leader>g', group = 'GotoPreview, GrugFar, Neogen' },
        { '<leader>g', group = 'GrugFar', mode = 'v' },
        { '<leader>l', group = 'LSP' },
        { '<leader>m', group = 'Mini' },
        { '<leader>mm', group = 'Mini.map' },
        { '<leader>n', group = 'Snacks' },
        { '<leader>nn', group = 'Snacks.notification' },
        { '<leader>nt', group = 'Snacks.toggle' },
        { '<leader>ns', group = 'Snacks.scratch' },
        { '<leader>r', group = 'Rename, ReSessison' },
        { '<leader>rs', group = 'ReSessison' },
        { '<leader>s', group = 'Telescopes' },
        { '<leader>t', group = 'Trouble' },
        { '<leader>tb', group = 'Trouble' },
        { '<leader>u', group = 'Utils' },
        { '<leader>uo', group = 'Utils.options' },
      }
    end,
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    enabled = not vim.g.options.enhance,
    event = 'BufRead',
    main = 'ibl',
    opts = {},
    config = function()
      require('ibl').setup {
        indent = {
          highlight = {
            'RainbowRed',
            'RainbowYellow',
            'RainbowBlue',
            'RainbowOrange',
            'RainbowGreen',
            'RainbowViolet',
            'RainbowCyan',
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
    event = 'InsertEnter',
    config = function()
      require('better_escape').setup {
        default_mappings = false,
        mappings = {
          i = {
            j = {
              j = '<Esc>',
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
    },
    config = function()
      require('smart-splits').setup {}
    end,
  },

  {
    'AckslD/nvim-neoclip.lua',
    event = 'BufRead',
    config = function()
      require('neoclip').setup {
        keys = {
          telescope = {
            i = {
              select = '<cr>',
              paste = '<A-p>',
              paste_behind = '<A-k>',
              replay = '<A-q>', -- replay a macro
              delete = '<A-d>', -- delete an entry
              edit = '<A-e>', -- edit an entry
              custom = {},
            },
          },
        },
      }
      vim.keymap.set(
        'n',
        '<leader>sc',
        '<cmd>Telescope neoclip<CR>',
        { desc = 'Telescope clipboard history' }
      )
    end,
  },

  {
    'LudoPinelli/comment-box.nvim',
    keys = {
      {
        '<leader>cbe',
        function()
          local line_start_pos = vim.fn.line '.'
          local line_end_pos = line_start_pos
          require('comment-box').llline(9, line_start_pos, line_end_pos)
        end,
        mode = 'n',
        desc = 'CommentBox Emphisis Box',
      },
      {
        '<leader>cbt',
        function()
          local line_start_pos = vim.fn.line '.'
          local line_end_pos = line_start_pos
          require('comment-box').llline(15, line_start_pos, line_end_pos)
        end,
        mode = 'n',
        desc = 'CommentBox Title Line',
      },
      {
        '<leader>cbb',
        function()
          local line_start_pos, line_end_pos
          if vim.api.nvim_get_mode().mode:match '[vV]' then
            line_start_pos = vim.fn.line 'v'
            line_end_pos = vim.fn.line '.'
            if line_start_pos > line_end_pos then
              line_start_pos, line_end_pos = line_end_pos, line_start_pos
            end
          else
            line_start_pos = vim.fn.line '.'
            line_end_pos = line_start_pos
          end
          require('comment-box').lcbox(10, line_start_pos, line_end_pos)
        end,
        mode = { 'n', 'v' },
        desc = 'CommentBox Content Box',
      },
      {
        '<leader>cbl',
        function()
          require('comment-box').line(15)
        end,
        mode = 'n',
        desc = 'CommentBox Line',
      },
      {
        '<leader>cbd',
        function()
          local line_start_pos, line_end_pos
          if vim.api.nvim_get_mode().mode:match '[vV]' then
            line_start_pos = vim.fn.line 'v'
            line_end_pos = vim.fn.line '.'
            if line_start_pos > line_end_pos then
              line_start_pos, line_end_pos = line_end_pos, line_start_pos
            end
          else
            line_start_pos = vim.fn.line '.'
            line_end_pos = line_start_pos
          end
          require('comment-box').dbox(line_start_pos, line_end_pos)
        end,
        mode = { 'n', 'v' },
        desc = 'CommentBox Delete',
      },
    },
    config = function()
      require('comment-box').setup {}
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

  {
    'tzachar/highlight-undo.nvim',
    event = 'BufRead',
    config = function()
      vim.api.nvim_set_hl(0, 'HighlightUndo', { link = 'Visual' })
      require('highlight-undo').setup()
    end,
  },

  require 'plugins.configs.ui',
  require 'plugins.configs.language',
  require 'plugins.configs.git',
  require 'plugins.configs.util',
  require 'plugins.configs.extras',
  require 'plugins.configs.telescope',
  require 'plugins.configs.explorer',
  require 'plugins.configs.tab',
  require 'plugins.configs.term',
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
