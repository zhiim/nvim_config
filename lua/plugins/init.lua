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
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup {}
    end,
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    event = 'BufRead',
    main = 'ibl',
    opts = {},
    config = function()
      local highlight = {
        'RainbowRed',
        'RainbowYellow',
        'RainbowBlue',
        'RainbowOrange',
        'RainbowGreen',
        'RainbowViolet',
        'RainbowCyan',
      }

      local colors = require('utils.util').get_palette()
      local hooks = require 'ibl.hooks'

      -- -- create the highlight groups in the highlight setup hook, so they are reset
      -- -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowRed', { fg = colors.red })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = colors.yellow })
        vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = colors.blue })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = colors.orange })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = colors.green })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = colors.magenta })
        vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = colors.cyan })
      end)

      require('ibl').setup {
        indent = {
          highlight = highlight,
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
      vim.keymap.set('n', '<leader>nc', '<cmd>Telescope neoclip<CR>', { desc = 'Open neoclip' })
    end,
  },

  {
    'LudoPinelli/comment-box.nvim',
    keys = {
      {
        '<leader>cbe',
        function()
          require('comment-box').llline(9)
        end,
        mode = 'n',
        desc = 'Comment Box Emphisis Box',
      },
      {
        '<leader>cbt',
        function()
          require('comment-box').llline(15)
        end,
        mode = 'n',
        desc = 'Comment Box Title Line',
      },
      {
        '<leader>cbb',
        function()
          require('comment-box').lcbox(10)
        end,
        mode = 'n',
        desc = 'Comment Box Content Box',
      },
      {
        '<leader>cbl',
        function()
          require('comment-box').line(15)
        end,
        mode = 'n',
        desc = 'Comment Box Line',
      },
      {
        '<leader>cbd',
        function()
          require('comment-box').dbox()
        end,
        mode = 'n',
        desc = 'Comment Box Delete',
      },
    },
    config = function()
      require('comment-box').setup {}
    end,
  },

  {
    'AndrewRadev/linediff.vim',
    cmd = { 'Linediff', 'LinediffReset' },
    keys = {
      {
        '<leader>ld',
        ':Linediff<cr>',
        mode = 'v',
        desc = 'Line Diff',
      },
      {
        '<leader>ldr',
        '<cmd>LinediffReset<CR>',
        desc = 'Line diff reset',
      },
    },
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
