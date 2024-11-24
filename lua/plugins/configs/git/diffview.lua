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
      desc = 'Diffview Open',
    },
    {
      '<leader>dc',
      '<cmd>DiffviewClose<cr>',
      mode = 'n',
      desc = 'Diffview Close',
    },
    {
      '<leader>dh',
      '<cmd>DiffviewFileHistory<cr>',
      mode = 'n',
      desc = 'Diffview View Files History',
    },
  },
}
