local color_scheme = vim.g.color_scheme or 'onedark'
local theme_plugins = {
  ['onedark'] = 'olimorris/onedarkpro.nvim',
  ['onenord'] = 'rmehri01/onenord.nvim',
  ['tokyonight'] = 'folke/tokyonight.nvim',
  ['nordic'] = 'AlexvZyl/nordic.nvim',
  ['catppuccin'] = 'catppuccin/nvim',
  ['material'] = 'marko-cerovac/material.nvim',
}
local theme = {
  theme_plugins[color_scheme],
  priority = 1000, -- Ensure it loads first
  config = function()
    local theme_style = vim.g.scheme_style or color_scheme
    vim.cmd.colorscheme(theme_style)
  end,
}

local copilot = {
  'github/copilot.vim',
}
if vim.g.use_copilot then
  copilot.event = 'VeryLazy'
end

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
      auto_install = false,
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
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)
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
    cmd = { 'BufferNext', 'BufferPrevious', 'BufferClose' },
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

      local colors = require('utils.util').get_palette(color_scheme)
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
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
    keys = {
      {
        '<leader>gen',
        function()
          require('neogen').generate { type = 'any' }
        end,
        mode = 'n',
        desc = 'Genearte annotation template',
      },
    },
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
    cmd = 'Trouble',
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
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    cmd = {
      'CopilotChatOpen',
      'CopilotChatClose',
      'CopilotChatToggle',
    },
    dependencies = {
      copilot,
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {
        max_lines = 3,
      }
    end,
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

  theme,
  require 'plugins.configs.telescope',
  require 'plugins.configs.cmp',
  require 'plugins.configs.lspconfig',
  require 'plugins.configs.gitsigns',
  -- require 'plugins.configs.debug',
  require 'plugins.configs.conform',
  require 'plugins.configs.lint',
  require 'plugins.configs.nvimtree',
  require 'plugins.configs.mini',
  require 'plugins.configs.lualine',
  require 'plugins.configs.dashboard',
  require 'plugins.configs.venv_selector',

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
