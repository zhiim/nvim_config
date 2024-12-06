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

    {
      'luukvbaal/statuscol.nvim',
      event = 'BufRead',
      enabled = vim.fn.has 'nvim-0.10',
      config = function()
        local builtin = require 'statuscol.builtin'
        require('statuscol').setup {
          relculright = true,
          ft_ignore = { 'codecompanion', 'copilot-chat', 'oil' },
          segments = {
            -- fold sign
            { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
            -- diagnostic sign
            {
              sign = { namespace = { 'diagnostic*' }, maxwidth = 1, colwidth = 1, auto = true },
              click = 'v:lua.ScSa',
            },
            -- empty space
            { text = { ' ' } },
            -- line number
            { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
            -- minidiff sign
            {
              sign = { namespace = { 'MiniDiff*' }, maxwidth = 1, colwidth = 1, auto = true },
              click = 'v:lua.ScSa',
            },
            -- all other signs
            {
              sign = { name = { '.*' }, text = { '.*' }, namespace = { '.*' }, maxwidth = 2, colwidth = 1, auto = true },
              click = 'v:lua.ScSa',
            },
            -- empty space
            { text = { ' ' } },
          },
        }
      end,
    },

    require 'plugins.configs.ui.dashboard',
    require 'plugins.configs.ui.lualine',
    require 'plugins.configs.ui.incline',
    require 'plugins.configs.ui.theme',
    require 'plugins.configs.ui.enhance',
    require 'plugins.configs.ui.noice',
    require 'plugins.configs.ui.dropbar',
    require 'plugins.configs.ui.ufo',
  }
else
  return {}
end
