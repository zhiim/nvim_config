local git_opts = vim.g.options.plugins.git

local graph_style = 'unicode'
if
  os.getenv 'TERM_PROGRAM' == 'WezTerm'
  or os.getenv 'TERM_PROGRAM' == 'ghostty'
  or os.getenv 'KITTY_WINDOW_ID'
then
  graph_style = 'kitty'
end

return {
  'NeogitOrg/neogit',
  lazy = true,
  enabled = vim.fn.has 'nvim-0.10' and git_opts.components.neogit
    or git_opts.enable_all,
  dependencies = {
    'm00qek/baleia.nvim',
  },
  cmd = 'Neogit',
  keys = {
    { '<leader>ng', '<cmd>Neogit<cr>', desc = 'Neogit UI' },
  },
  config = function()
    local neogit = require 'neogit'
    neogit.setup {
      graph_style = graph_style,
    }
  end,
}
