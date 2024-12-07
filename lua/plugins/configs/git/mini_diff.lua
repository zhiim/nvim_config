return {
  'echasnovski/mini.diff',
  event = 'VeryLazy',
  version = false,
  keys = {
    {
      '<leader>mdt',
      function()
        require('mini.diff').toggle_overlay(0)
      end,
      desc = 'Git toggle mini.diff overlay',
    },
  },
  opts = {
    view = {
      style = 'sign',
      signs = {
        add = '▎',
        change = '▎',
        delete = '',
      },
    },
  },
}
