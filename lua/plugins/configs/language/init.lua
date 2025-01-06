if vim.g.options.language_support then
  return {
    {
      'danymat/neogen',
      dependencies = 'nvim-treesitter/nvim-treesitter',
      config = true,
      keys = {
        {
          '<leader>ge',
          function()
            require('neogen').generate { type = 'any' }
            require('neogen').setup { snippet_engine = 'luasnip' }
          end,
          mode = 'n',
          desc = 'LSP genearte annotation template',
        },
      },
      -- Uncomment next line if you want to follow only stable versions
      -- version = "*"
    },

    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'echasnovski/mini.icons',
      },
      ft = { 'markdown', 'codecompanion', 'copilot-chat' },
      config = function()
        require('render-markdown').setup {}
      end,
    },

    {
      'linux-cultist/venv-selector.nvim',
      dependencies = {
        'neovim/nvim-lspconfig',
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
        {
          '<leader>sv',
          '<cmd>VenvSelect<cr>',
          mode = 'n',
          desc = 'Select Python virtual environment',
        },
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
          '<leader>gtd',
          function()
            require('goto-preview').goto_preview_definition {}
          end,
          mode = 'n',
          desc = 'GotoPrevew go to definitions',
        },
        {
          '<leader>gtr',
          function()
            require('goto-preview').goto_preview_references()
          end,
          mode = 'n',
          desc = 'GotoPrevew go to references',
        },
        {
          '<leader>gtD',
          function()
            require('goto-preview').goto_preview_declaration {}
          end,
          mode = 'n',
          desc = 'GotoPrevew go to declarations',
        },
        {
          '<leader>gtt',
          function()
            require('goto-preview').goto_preview_type_definition {}
          end,
          mode = 'n',
          desc = 'GotoPrevew go to type definitions',
        },
        {
          '<leader>gti',
          function()
            require('goto-preview').goto_preview_implementation {}
          end,
          mode = 'n',
          desc = 'GotoPrevew go to implementations',
        },
        {
          '<leader>gtc',
          function()
            require('goto-preview').close_all_win()
          end,
          mode = 'n',
          desc = 'GotoPrevew close all preview windows',
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
          '<leader>tw',
          '<cmd>Trouble diagnostics toggle<cr>',
          desc = 'Trouble Workspace Diagnostics',
        },
        {
          '<leader>tb',
          '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
          desc = 'Trouble Buffer Diagnostics',
        },
        {
          '<leader>ts',
          '<cmd>Trouble symbols toggle<cr>',
          desc = 'Trouble Symbols',
        },
        {
          '<leader>tl',
          '<cmd>Trouble lsp toggle<cr>',
          desc = 'Trouble LSP Definitions / references / ...',
        },
        {
          '<leader>tL',
          '<cmd>Trouble loclist toggle<cr>',
          desc = 'Trouble Location List',
        },
        {
          '<leader>tq',
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
      cmd = 'IncRename',
      keys = {
        {
          '<leader>rn',
          function()
            return ':IncRename ' .. vim.fn.expand '<cword>'
          end,
          mode = 'n',
          desc = 'LSP incremental Rename',
          expr = true,
        },
      },
    },

    {
      'folke/lazydev.nvim',
      ft = 'lua',
      dependencies = {
        { 'gonstoll/wezterm-types', lazy = true },
      },
      opts = {
        library = {
          'snacks.nvim',
          -- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          { path = 'wezterm-types', mods = { 'wezterm' } },
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
