if vim.g.options.util then
  return {
    {
      'folke/flash.nvim',
      event = 'BufRead',
      opts = {
        modes = {
          search = {
            enabled = true,
          },
        },
      },
      keys = {
        {
          '<leader>fl',
          mode = { 'c', 'n' },
          function()
            require('flash').toggle()
          end,
          desc = 'Flash Toggle',
        },
        {
          '<leader>fj',
          mode = { 'n', 'x', 'o' },
          function()
            require('flash').jump()
          end,
          desc = 'Flash jump',
        },
        {
          '<leader>ft',
          mode = { 'n', 'x', 'o' },
          function()
            require('flash').treesitter()
          end,
          desc = 'Flash Treesitter',
        },
        {
          '<leader>fr',
          mode = 'o',
          function()
            require('flash').remote()
          end,
          desc = 'Flash remote',
        },
        {
          '<leader>fs',
          mode = { 'n', 'o', 'x' },
          function()
            require('flash').treesitter_search()
          end,
          desc = 'Flash treesitter search',
        },
      },
    },

    {
      'MagicDuck/grug-far.nvim',
      cmd = 'GrugFar',
      opts = {
        keymaps = {
          close = { n = 'q' },
        },
      },
      keys = {
        {
          '<leader>gf',
          function()
            local grug = require 'grug-far'
            local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
            grug.open {
              transient = true,
              prefills = {
                filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
              },
            }
          end,
          mode = { 'n', 'v' },
          desc = 'GrugFar search and replace',
        },
      },
    },

    {
      'echasnovski/mini.surround',
      event = 'BufRead',
      version = false,
      config = function()
        require('mini.surround').setup {}
      end,
    },

    {
      'cbochs/portal.nvim',
      keys = {
        {
          '<leader>pj',
          function()
            require('portal.builtin').jumplist.tunnel()
          end,
          mode = 'n',
          desc = 'Portal jumplist',
        },
        {
          '<leader>pc',
          function()
            require('portal.builtin').changelist.tunnel()
          end,
          mode = 'n',
          desc = 'Portal changelist',
        },
      },
      config = function()
        require('portal').setup {
          escape = {
            ['q'] = true,
          },
          window_options = {
            border = 'rounded',
            height = 5,
          },
        }
      end,
    },

    {
      'cbochs/grapple.nvim',
      opts = {
        scope = 'git', -- default scope when creating a new tag
      },
      cmd = 'Grapple',
      keys = {
        {
          '<leader>gpt',
          function()
            require('grapple').toggle()
          end,
          desc = 'Grapple toggle tag',
        },
        {
          '<leader>gpT',
          function()
            require('grapple').toggle { scope = 'global' }
          end,
          desc = 'Grapple toggle global tag',
        },
        {
          '<leader>gpw',
          function()
            require('grapple').open_tags()
          end,
          desc = 'Grapple open tags window',
        },
        {
          '<leader>gpW',
          function()
            require('grapple').open_tags { scope = 'global' }
          end,
          desc = 'Grapple open global tags window',
        },
      },
      config = function()
        require('grapple').setup {
          win_opts = {
            border = 'rounded',
          },
        }
      end,
    },

    require 'plugins.configs.util.minimap',
    require 'plugins.configs.util.snacks',
    require 'plugins.configs.util.session',
  }
else
  return {}
end
