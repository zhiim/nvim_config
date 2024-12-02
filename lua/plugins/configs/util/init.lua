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
          '<leader>fll',
          mode = { 'c', 'n' },
          function()
            require('flash').toggle()
          end,
          desc = 'Flash Toggle',
        },
        {
          '<leader>flj',
          mode = { 'n', 'x', 'o' },
          function()
            require('flash').jump()
          end,
          desc = 'Flash',
        },
        {
          '<leader>flt',
          mode = { 'n', 'x', 'o' },
          function()
            require('flash').treesitter()
          end,
          desc = 'Flash Treesitter',
        },
        {
          '<leader>flr',
          mode = 'o',
          function()
            require('flash').remote()
          end,
          desc = 'Remote Flash',
        },
        {
          '<leader>fls',
          mode = { 'n', 'o', 'x' },
          function()
            require('flash').treesitter_search()
          end,
          desc = 'Treesitter Search',
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
          desc = 'Search and Replace',
        },
      },
    },

    require 'plugins.configs.util.minimap',
    require 'plugins.configs.util.snacks',
    require 'plugins.configs.util.session',
  }
else
  return {}
end
