if vim.g.options.language_support then
  return {
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
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
      ft = { 'markdown', 'codecompanion', 'copilot-chat' },
      config = function()
        require('render-markdown').setup {}
        vim.keymap.set('n', '<leader>rmt', '<cmd>RenderMarkdown toggle<CR>', { desc = 'Toggle markdown preview' })
      end,
    },

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

    {
      'linux-cultist/venv-selector.nvim',
      dependencies = {
        'neovim/nvim-lspconfig',
        { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
      },
      event = 'BufEnter *.py', -- lazy load when entering python files
      branch = 'regexp', -- This is the regexp branch, use this for the new version
      config = function()
        require('venv-selector').setup {
          settings = {
            search = {
              find_conda = {
                command = vim.g.options.python_conda_command,
              },
              find_venv = {
                command = vim.g.options.python_venv_command,
              },
            },
          },
        }
      end,
      keys = {
        { '<leader>pvs', '<cmd>VenvSelect<cr>', mode = 'n', desc = 'Python Virtual Environment Selection' },
      },
    },

    {
      'ray-x/lsp_signature.nvim',
      event = 'InsertEnter',
      opts = {
        hint_prefix = ' ',
        floating_window_off_x = 5, -- adjust float windows x position.
        floating_window_off_y = function() -- adjust float windows y position. e.g. set to -2 can make floating window move up 2 lines
          local pumheight = vim.o.pumheight
          local winline = vim.fn.winline() -- line number in the window
          local winheight = vim.fn.winheight(0)

          -- window top
          if winline - 1 < pumheight then
            return pumheight
          end

          -- window bottom
          if winheight - winline < pumheight then
            return -pumheight
          end
          return 0
        end,
      },
      config = function(_, opts)
        require('lsp_signature').setup(opts)
      end,
    },

    {
      'rmagatti/goto-preview',
      keys = {
        {
          '<leader>gd',
          function()
            require('goto-preview').goto_preview_definition {}
          end,
          mode = 'n',
          desc = 'Go to definitions',
        },
        {
          '<leader>gr',
          function()
            require('goto-preview').goto_preview_references()
          end,
          mode = 'n',
          desc = 'Go to references',
        },
        {
          '<leader>gD',
          function()
            require('goto-preview').goto_preview_declaration {}
          end,
          mode = 'n',
          desc = 'Go to declarations',
        },
        {
          '<leader>gt',
          function()
            require('goto-preview').goto_preview_type_definition {}
          end,
          mode = 'n',
          desc = 'Go to type definitions',
        },
        {
          '<leader>gi',
          function()
            require('goto-preview').goto_preview_implementation {}
          end,
          mode = 'n',
          desc = 'Go to implementations',
        },
        {
          '<leader>gc',
          function()
            require('goto-preview').close_all_win()
          end,
          mode = 'n',
          desc = 'Go to implementations',
        },
      },
      config = function()
        require('goto-preview').setup {
          border = { '↖', '─', '╮', '│', '╯', '─', '╰', '│' },
        }
      end,
    },

    {
      'folke/trouble.nvim',
      cmd = 'Trouble',
      keys = {
        {
          '<leader>tbw',
          '<cmd>Trouble diagnostics toggle<cr>',
          desc = 'Trouble Workspace Diagnostics',
        },
        {
          '<leader>tbb',
          '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
          desc = 'Trouble Buffer Diagnostics',
        },
        {
          '<leader>tbs',
          '<cmd>Trouble symbols toggle<cr>',
          desc = 'Trouble Symbols',
        },
        {
          '<leader>tbl',
          '<cmd>Trouble lsp toggle<cr>',
          desc = 'Trouble LSP Definitions / references / ...',
        },
        {
          '<leader>tbL',
          '<cmd>Trouble loclist toggle<cr>',
          desc = 'Trouble Location List',
        },
        {
          '<leader>tbq',
          '<cmd>Trouble qflist toggle<cr>',
          desc = 'Trouble Quickfix List',
        },
      },
      config = function()
        require('trouble').setup {
          auto_close = true, -- auto close when there are no items
          focus = false, -- Focus the window when opened
          modes = {
            symbols = {
              focus = true,
            },
          },
        }
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
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          'snacks.nvim',
          -- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },

    require 'plugins.configs.language.lspconfig',
    require 'plugins.configs.language.treesitter',
    require 'plugins.configs.language.cmp',
    require 'plugins.configs.language.conform',
    require 'plugins.configs.language.lint',
    require 'plugins.configs.language.debug',
    require 'plugins.configs.language.symbol_usage',
  }
else
  return {}
end
