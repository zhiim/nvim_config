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
      '<leader>dvo',
      '<cmd>DiffviewOpen<cr>',
      mode = 'n',
      desc = 'Git Diffview open',
    },
    {
      '<leader>dvc',
      '<cmd>DiffviewClose<cr>',
      mode = 'n',
      desc = 'Git Diffview close',
    },
    {
      '<leader>dvh',
      '<cmd>DiffviewFileHistory<cr>',
      mode = 'n',
      desc = 'Git Diffview view current branch files history',
    },
    {
      '<leader>dvf',
      '<cmd>DiffviewFileHistory %<cr>',
      mode = 'n',
      desc = 'Git Diffview view current file history',
    },
  },
  opts = {
    view = {
      merge_tool = {
        layout = 'diff3_mixed',
      },
    },
  },
}
