if not vim.g.options.enable_language_support then
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
        ensure_installed = { 'bash', 'c', 'cpp', 'python', 'diff', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'vim', 'vimdoc' },
        -- Autoinstall languages that are not installed
        auto_install = false,
        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'ruby', 'latex' },
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
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
      ft = 'markdown',
      config = function()
        require('render-markdown').setup {}
        vim.keymap.set('n', '<leader>rmt', '<cmd>RenderMarkdown toggle<CR>', { desc = 'Toggle markdown preview' })
      end,
    },

    -- Lua
    {
      'folke/twilight.nvim',
      cmd = 'Twilight',
      keys = {
        {
          '<leader>tw',
          '<cmd>Twilight<cr>',
          mode = 'n',
          desc = 'Twilight Toggle',
        },
      },
    },
  }
end
