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
        { '<leader>vs', '<cmd>VenvSelect<cr>' },
      },
    },

    {
      'ray-x/lsp_signature.nvim',
      event = 'InsertEnter',
      opts = {
        hint_prefix = ' ',
        floating_window_off_x = 5, -- adjust float windows x position.
        floating_window_off_y = function() -- adjust float windows y position. e.g. set to -2 can make floating window move up 2 lines
          local linenr = vim.api.nvim_win_get_cursor(0)[1] -- buf line number
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
      'dnlhc/glance.nvim',
      cmd = 'Glance',
      keys = {
        {
          '<leader>gd',
          '<CMD>Glance definitions<CR>',
          mode = 'n',
          desc = 'Glance definitions',
        },
        {
          '<leader>gr',
          '<CMD>Glance references<CR>',
          mode = 'n',
          desc = 'Glance references',
        },
        {
          '<leader>gD',
          '<CMD>Glance type_definitions<CR>',
          mode = 'n',
          desc = 'Glance type definitions',
        },
        {
          '<leader>gI',
          '<CMD>Glance implementations<CR>',
          mode = 'n',
          desc = 'Glance implementations',
        },
      },
      config = function()
        local actions = require('glance').actions
        local opt = {
          mappings = {
            preview = {
              ['q'] = actions.close,
            },
          },
        }
        require('glance').setup(opt)
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

    require 'plugins.configs.language.lspconfig',
    require 'plugins.configs.language.treesitter',
    require 'plugins.configs.language.cmp',
    require 'plugins.configs.language.conform',
    require 'plugins.configs.language.lint',
    require 'plugins.configs.language.debug',
  }
else
  return {}
end
