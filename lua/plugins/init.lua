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
      require('which-key').register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
      }
      -- visual mode
      require('which-key').register({
        ['<leader>h'] = { 'Git [H]unk' },
      }, { mode = 'v' })
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      --
      -- NOTE: language parsers need to be installed
      --
      ensure_installed = { 'bash', 'c', 'cpp', 'python', 'diff', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- Optional dependency
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup {}
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    event = 'BufEnter',
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      auto_hide = 1,
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
    keys = {
      { '<tab>', '<Cmd>BufferNext<CR>', mode = 'n', desc = 'buffer goto next' },
      { '<S-tab>', '<Cmd>BufferPrevious<CR>', mode = 'n', desc = 'buffer goto previous' },
      { '<leader>x', '<Cmd>BufferClose<CR>', mode = 'n', desc = 'buffer close' },
    },
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  {
    'max397574/better-escape.nvim',
    event = 'InsertEnter',
    config = function()
      require('better_escape').setup()
    end,
  },

  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },

  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
  },

  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
  },

  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'TroubleToggle',
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  {
    'ellisonleao/glow.nvim',
    config = true,
    cmd = 'Glow',
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
    'olimorris/onedarkpro.nvim',
    priority = 1000, -- Ensure it loads first
    config = function()
      vim.cmd 'colorscheme onedark_vivid'
    end,
  },

  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    -- event = "VeryLazy",
    cmd = {
      'CopilotChatOpen',
      'CopilotChatClose',
      'CopilotChatToggle',
    },
    dependencies = {
      {
        'github/copilot.vim',
        -- event = "VeryLazy",
      },
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  {
    'NvChad/nvterm',
    config = function()
      local is_windows = vim.fn.has 'win32' ~= 0
      if is_windows then
        vim.o.shell = vim.fn.executable 'pwsh' and 'pwsh' or 'powershell'
        vim.o.shellcmdflag =
          '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
        vim.o.shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
        vim.o.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
        vim.o.shellquote = ''
        vim.o.shellxquote = ''
      end
      require('nvterm').setup {}
    end,
  },

  require 'plugins.configs.telescope',
  require 'plugins.configs.cmp',
  require 'plugins.configs.lspconfig',
  require 'plugins.configs.gitsigns',
  -- require 'plugins.configs.debug',
  require 'plugins.configs.conform',
  require 'plugins.configs.lint',
  require 'plugins.configs.nvimtree',
  require 'plugins.configs.mini',

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
