if vim.g.options.ui then
  return {
    {
      'norcalli/nvim-colorizer.lua',
      event = 'BufRead',
      config = function()
        require('colorizer').setup()
      end,
    },

    -- Highlight todo, notes, etc in comments
    {
      'folke/todo-comments.nvim',
      event = 'BufRead',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = { signs = false },
    },

    require 'plugins.configs.ui.dashboard',
    require 'plugins.configs.ui.lualine',
    require 'plugins.configs.ui.incline',
    require 'plugins.configs.ui.theme',
    require 'plugins.configs.ui.enhance',
    require 'plugins.configs.ui.noice',
    require 'plugins.configs.ui.dropbar',
  }
else
  return {}
end
