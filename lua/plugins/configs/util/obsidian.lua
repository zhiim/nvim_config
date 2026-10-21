local util_opts = vim.g.options.plugins.util

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  enabled = vim.fn.has 'nvim-0.11' and util_opts.components.obsidian
    or util_opts.enable_all,
  lazy = true,
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('obsidian').setup {
      legacy_commands = false,
      link = {
        style = 'markdown',
        format = 'relative',
        auto_update = false,
      },
      workspaces = {
        {
          name = 'obsidian',
          path = '~/Documents/Obsidian/',
        },
      },
      picker = {
        name = vim.g.options.picker.chosen == 1 and 'fzf-lua'
          or 'telescope.nvim',
      },
      attachments = {
        folder = './attachments',
      },
      frontmatter = {
        enabled = false,
      },
    }
  end,
}
