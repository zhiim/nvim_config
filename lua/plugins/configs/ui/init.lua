local ui_opts = vim.g.options.plugins.ui

if vim.g.options.mode.chosen == 2 then
  return {
    {
      'norcalli/nvim-colorizer.lua',
      event = 'BufRead',
      enabled = ui_opts.components.nvim_colorizer or ui_opts.enable_all,
      config = function()
        require('colorizer').setup()
      end,
    },

    -- Highlight todo, notes, etc in comments
    {
      'folke/todo-comments.nvim',
      event = 'BufRead',
      enabled = ui_opts.components.todo_comments or ui_opts.enable_all,
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = { signs = false },
    },

    {
      'luukvbaal/statuscol.nvim',
      event = 'BufRead',
      enabled = vim.fn.has 'nvim-0.10' and ui_opts.components.statuscol
        or ui_opts.enable_all,
      config = function()
        local builtin = require 'statuscol.builtin'
        require('statuscol').setup {
          relculright = true,
          ft_ignore = {
            'codecompanion',
            'copilot-chat',
            'oil',
            'neo-tree',
            'NvimTree',
            'toggleterm',
            'repl',
            'fyler',
          },
          segments = {
            -- diagnostic sign
            {
              sign = {
                namespace = { 'diagnostic*' },
                maxwidth = 1,
                colwidth = 1,
                auto = true,
              },
              click = 'v:lua.ScSa',
            },
            -- line number
            { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
            -- minidiff sign
            {
              sign = {
                namespace = { 'MiniDiff*' },
                maxwidth = 1,
                colwidth = 1,
                auto = true,
              },
              click = 'v:lua.ScSa',
            },
            -- all other signs
            {
              sign = {
                name = { '.*' },
                text = { '.*' },
                namespace = { '.*' },
                maxwidth = 2,
                colwidth = 2,
                auto = true,
              },
              click = 'v:lua.ScSa',
            },
            -- fold sign
            { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
          },
        }
      end,
    },

    {
      'rachartier/tiny-glimmer.nvim',
      enabled = vim.fn.has 'nvim-0.10' and ui_opts.components.tiny_glimmer
        or ui_opts.enable_all,
      event = 'VeryLazy',
      config = function()
        local palette = require('utils.palette').get_palette()
        local opts = {
          default_animation = 'left_to_right',
          overwrite = {
            auto_map = true,
            search = {
              enabled = true,
              default_animation = 'left_to_right',
            },
            paste = {
              enabled = true,
              default_animation = 'left_to_right',
            },
            undo = {
              enabled = true,
              default_animation = 'left_to_right',
            },
            redo = {
              enabled = true,
              default_animation = 'left_to_right',
            },
          },
          animations = {
            left_to_right = {
              from_color = palette.red,
              to_color = palette.blue,
            },
          },
        }
        require('tiny-glimmer').setup(opts)
      end,
    },

    require 'plugins.configs.ui.dashboard',
    require 'plugins.configs.ui.lualine',
    -- require 'plugins.configs.ui.incline',
    require 'plugins.configs.ui.enhance',
    require 'plugins.configs.ui.noice',
    require 'plugins.configs.ui.dropbar',
    require 'plugins.configs.ui.ufo',
  }
else
  return {}
end
