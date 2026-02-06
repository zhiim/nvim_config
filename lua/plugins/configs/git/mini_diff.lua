local git_opts = vim.g.options.plugins.git

return {
  'echasnovski/mini.diff',
  enabled = git_opts.components.mini_diff or git_opts.enable_all,
  event = 'VeryLazy',
  version = false,
  keys = {
    {
      '<leader>md',
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
    options = {
      algorithm = 'histogram',
      indent_heuristic = true,
      linematch = 40,
      wrap_goto = false,
    },
  },
}
