require('lazy').setup({

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>c_', hidden = true },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>d_', hidden = true },
        { '<leader>h', group = 'Git [H]unk' },
        { '<leader>h_', hidden = true },
        { '<leader>r', group = '[R]ename' },
        { '<leader>r_', hidden = true },
        { '<leader>s', group = '[S]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>t_', hidden = true },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>w_', hidden = true },
      }
      -- visual mode
      require('which-key').add({
        { '<leader>h', desc = 'Git [H]unk', mode = 'v' },
      }, { mode = 'v' })
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
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
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowRed', { fg = colors.red })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = colors.yellow })
        vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = colors.blue })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = colors.orange })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = colors.green })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = colors.purple })
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
      require('better_escape').setup()
    end,
  },

  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    config = function()
      require('smart-splits').setup {}
    end,
  },

  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'Trouble',
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewRefresh',
      'DiffviewToggleFile',
      'DiffviewNext',
      'DiffviewPrev',
      'DiffviewFileHistory',
    },
  },

  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<C-\>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_terminals = false,
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        persist_size = true,
        direction = 'horizontal',
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
      }
    end,
  },

  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },

  {
    'smjonas/inc-rename.nvim',
    config = function()
      require('inc_rename').setup {}
    end,
    keys = {
      {
        '<leader>rn',
        function()
          require('inc_rename').rename()
        end,
        mode = 'n',
        desc = 'Incremental Rename',
      },
    },
  },

  {
    'AckslD/nvim-neoclip.lua',
    dependencies = {
      -- you'll need at least one of these
      -- {'nvim-telescope/telescope.nvim'},
      -- {'ibhagwan/fzf-lua'},
    },
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
          require('comment-box').ccbox(10)
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
      require('comment-box').setup {
        box_width = 76,
      }
    end,
  },

  require 'plugins.configs.telescope',
  require 'plugins.configs.cmp',
  require 'plugins.configs.lspconfig',
  require 'plugins.configs.treesitter',
  require 'plugins.configs.gitsigns',
  require 'plugins.configs.debug',
  require 'plugins.configs.conform',
  require 'plugins.configs.lint',
  require 'plugins.configs.explorer',
  require 'plugins.configs.mini',
  require 'plugins.configs.lualine',
  require 'plugins.configs.dashboard',
  require 'plugins.configs.venv_selector',
  require 'plugins.configs.theme',
  require 'plugins.configs.copilot',
  require 'plugins.configs.vimtex',
  require 'plugins.configs.leetcode',
  require 'plugins.configs.tab',

  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'custom.plugins' },
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
