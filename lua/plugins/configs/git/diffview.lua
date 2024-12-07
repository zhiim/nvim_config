return {
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
  keys = {
    {
      '<leader>dv',
      '<cmd>DiffviewOpen<cr>',
      mode = 'n',
      desc = 'Git Diffview open',
    },
    {
      '<leader>dc',
      '<cmd>DiffviewClose<cr>',
      mode = 'n',
      desc = 'Git Diffview close',
    },
    {
      '<leader>dh',
      '<cmd>DiffviewFileHistory<cr>',
      mode = 'n',
      desc = 'Git Diffview view files history',
    },
  },
}
