if not vim.g.enable_language_support then
  return {}
else
  return { -- Highlight, edit, and navigate code
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      opts = {
        --
        -- NOTE: language parsers need to be installed
        --
        ensure_installed = { 'bash', 'c', 'cpp', 'python', 'diff', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
        ignore_install = { 'latex' },
        -- Autoinstall languages that are not installed
        auto_install = false,
        highlight = {
          enable = true,
          disable = { 'latex' },
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
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        require('treesitter-context').setup {
          max_lines = 3,
        }
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
            require('neogen').setup { snippet_engine = 'luasnip' }
          end,
          mode = 'n',
          desc = 'Genearte annotation template',
        },
      },
      -- Uncomment next line if you want to follow only stable versions
      -- version = "*"
    },

    {
      'stevearc/aerial.nvim',
      opts = {},
      -- Optional dependencies
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
      },
      keys = {
        {
          '<leader>at',
          function()
            require('aerial').toggle()
          end,
          mode = 'n',
          desc = 'Toggle aerial',
        },
        {
          '{',
          function()
            require('aerial').prev()
          end,
          mode = 'n',
          desc = 'Jump to previous node',
        },
        {
          '}',
          function()
            require('aerial').next()
          end,
          mode = 'n',
          desc = 'Jump to next node',
        },
      },
    },

    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
      ft = 'markdown',
      config = function()
        require('render-markdown').setup {}
        vim.keymap.set('n', '<leader>rmt', '<cmd>RenderMarkdown toggle<CR>', { desc = 'Toggle markdown preview' })
      end,
    },
  }
end
