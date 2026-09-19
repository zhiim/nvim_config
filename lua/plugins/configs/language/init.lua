local language_opts = vim.g.options.plugins.language

if vim.g.options.mode.chosen == 2 then
  return {
    {
      'danymat/neogen',
      enabled = (
        language_opts.components.neogen
        and language_opts.components.basic.enabled
      ) or language_opts.enable_all,
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
      ft = {
        'markdown',
        'codecompanion',
        'copilot-chat',
      },
      enabled = vim.fn.has 'nvim-0.9'
          and language_opts.components.render_markdown
        or language_opts.enable_all,
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-mini/mini.icons',
      },
      config = function()
        require('render-markdown').setup {
          file_types = {
            'markdown',
            'codecompanion',
            'copilot-chat',
          },
        }
      end,
    },

    {
      'linux-cultist/venv-selector.nvim',
      enabled = vim.fn.has 'nvim-0.9'
          and (language_opts.components.render_markdown and language_opts.components.basic.enabled)
        or language_opts.enable_all,
      dependencies = {
        'neovim/nvim-lspconfig',
      },
      event = 'BufEnter *.py', -- lazy load when entering python files
      config = function()
        require('venv-selector').setup {
          options = {
            picker_icons = {
              cwd = ' ',
              workspace = ' ',
              file = ' ',
              virtualenvs = ' ',
              hatch = ' ',
              poetry = ' ',
              pyenv = ' ',
              anaconda_envs = ' ',
              anaconda_base = ' ',
              miniconda_envs = ' ',
              miniconda_base = ' ',
              pipx = ' ',
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
      'dnlhc/glance.nvim',
      enabled = vim.fn.has 'nvim-0.9'
          and (language_opts.components.glance and language_opts.components.basic.enabled)
        or language_opts.enable_all,
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
      enabled = vim.fn.has 'nvim-0.9.2'
          and (language_opts.components.trouble and language_opts.components.basic.enabled)
        or language_opts.enable_all,
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
      enabled = vim.fn.has 'nvim-0.8'
          and (language_opts.components.inc_rename and language_opts.components.basic.enabled)
        or language_opts.enable_all,
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
      enabled = vim.fn.has 'nvim-0.10'
        and (language_opts.components.basic.enabled or language_opts.enable_all),
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

    require 'plugins.configs.language.mason',
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
