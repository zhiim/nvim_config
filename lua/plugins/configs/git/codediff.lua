local git_opts = vim.g.options.plugins.git

return {
  'esmuellert/codediff.nvim',
  enabled = vim.fn.has 'nvim-0.10' and git_opts.components.codediff
    or git_opts.enable_all,
  dependencies = { 'MunifTanjim/nui.nvim' },
  cmd = 'CodeDiff',
  keys = {
    {
      '<leader>dv',
      '<cmd>CodeDiff<cr>',
      mode = 'n',
      desc = 'Git Diffview open',
    },
  },
  config = function()
    require('codediff').setup {
      explorer = {
        position = 'left',
        width = 40,
        indent_markers = true,
        icons = {
          folder_closed = '󰉋',
          folder_open = '󰝰',
        },
        view_mode = 'list',
      },

      keymaps = {
        view = {
          quit = 'q',
          toggle_explorer = '<leader>b',
          next_hunk = ']h',
          prev_hunk = '[h',
          next_file = ']f',
          prev_file = '[f',
          diff_get = 'do',
          diff_put = 'dp',
        },
        explorer = {
          select = '<CR>',
          hover = 'K',
          refresh = 'R',
          toggle_view_mode = '<C-s>',
        },
      },
    }
  end,
}
