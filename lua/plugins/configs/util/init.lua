if vim.g.options.mode == 'IDE' then
  return {
    -- "gc" to comment visual regions/lines
    {
      'numToStr/Comment.nvim',
      event = 'BufRead',
      opts = {},
    },

    {
      'AckslD/nvim-neoclip.lua',
      event = 'BufRead',
      config = function()
        require('neoclip').setup {
          keys = {
            telescope = {
              i = {
                select = '<cr>',
                paste = '<A-p>',
                paste_behind = '<A-k>',
                replay = '<A-q>', -- replay a macro
                delete = '<A-d>', -- delete an entry
                edit = '<A-e>', -- edit an entry
                custom = {},
              },
            },
            fzf = {
              select = 'default',
              paste = 'alt-p',
              paste_behind = 'alt-k',
            },
          },
        }
        if vim.g.options.picker == 'telescope' then
          vim.keymap.set(
            'n',
            '<leader>sc',
            '<cmd>Telescope neoclip<CR>',
            { desc = 'Telescope search clipboard' }
          )
        else
          vim.keymap.set('n', '<leader>sc', function()
            require 'neoclip.fzf'()
          end, { desc = 'FzfLua search clipboard' })
        end
      end,
    },

    {
      'LudoPinelli/comment-box.nvim',
      keys = {
        {
          '<leader>cbe',
          function()
            local line_start_pos = vim.fn.line '.'
            local line_end_pos = line_start_pos
            require('comment-box').llline(9, line_start_pos, line_end_pos)
          end,
          mode = 'n',
          desc = 'CommentBox Emphisis Box',
        },
        {
          '<leader>cbt',
          function()
            local line_start_pos = vim.fn.line '.'
            local line_end_pos = line_start_pos
            require('comment-box').llline(15, line_start_pos, line_end_pos)
          end,
          mode = 'n',
          desc = 'CommentBox Title Line',
        },
        {
          '<leader>cbb',
          function()
            local line_start_pos, line_end_pos
            if vim.api.nvim_get_mode().mode:match '[vV]' then
              line_start_pos = vim.fn.line 'v'
              line_end_pos = vim.fn.line '.'
              if line_start_pos > line_end_pos then
                line_start_pos, line_end_pos = line_end_pos, line_start_pos
              end
            else
              line_start_pos = vim.fn.line '.'
              line_end_pos = line_start_pos
            end
            require('comment-box').lcbox(10, line_start_pos, line_end_pos)
          end,
          mode = { 'n', 'v' },
          desc = 'CommentBox Content Box',
        },
        {
          '<leader>cbl',
          function()
            require('comment-box').line(15)
          end,
          mode = 'n',
          desc = 'CommentBox Line',
        },
        {
          '<leader>cbd',
          function()
            local line_start_pos, line_end_pos
            if vim.api.nvim_get_mode().mode:match '[vV]' then
              line_start_pos = vim.fn.line 'v'
              line_end_pos = vim.fn.line '.'
              if line_start_pos > line_end_pos then
                line_start_pos, line_end_pos = line_end_pos, line_start_pos
              end
            else
              line_start_pos = vim.fn.line '.'
              line_end_pos = line_start_pos
            end
            require('comment-box').dbox(line_start_pos, line_end_pos)
          end,
          mode = { 'n', 'v' },
          desc = 'CommentBox Delete',
        },
      },
      config = function()
        require('comment-box').setup {}
      end,
    },

    {
      'folke/flash.nvim',
      event = 'BufRead',
      opts = {
        search = {
          exclude = {
            'notify',
            'cmp_menu',
            'noice',
            'flash_prompt',
            'blink-cmp-menu',
            function(win)
              -- exclude non-focusable windows
              return not vim.api.nvim_win_get_config(win).focusable
            end,
          },
        },
        modes = {
          search = {
            enabled = false, -- enable this will disort the search result process
          },
        },
      },
      keys = {
        {
          '<C-s>',
          mode = { 'c' },
          function()
            require('flash').toggle()
          end,
          desc = 'Flash Toggle',
        },
        {
          ']f',
          mode = { 'n', 'x', 'o' },
          function()
            require('flash').jump()
          end,
          desc = 'Jump with Flash',
        },
        {
          ']F',
          mode = { 'n', 'o', 'x' },
          function()
            require('flash').treesitter_search()
          end,
          desc = 'Jump with Flash treesitter search',
        },
      },
    },

    {
      'MagicDuck/grug-far.nvim',
      cmd = 'GrugFar',
      opts = {
        keymaps = {
          close = { n = 'q' },
        },
      },
      keys = {
        {
          '<leader>gf',
          function()
            local grug = require 'grug-far'
            local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
            grug.open {
              transient = true,
              prefills = {
                filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
              },
            }
          end,
          mode = { 'n', 'v' },
          desc = 'GrugFar search and replace',
        },
      },
    },

    {
      'echasnovski/mini.surround',
      event = 'BufRead',
      version = false,
      config = function()
        require('mini.surround').setup {}
      end,
    },

    {
      'cbochs/portal.nvim',
      keys = {
        {
          '<leader>pj',
          function()
            require('portal.builtin').jumplist.tunnel()
          end,
          mode = 'n',
          desc = 'Portal jumplist',
        },
        {
          '<leader>pc',
          function()
            require('portal.builtin').changelist.tunnel()
          end,
          mode = 'n',
          desc = 'Portal changelist',
        },
      },
      config = function()
        require('portal').setup {
          escape = {
            ['q'] = true,
          },
          window_options = {
            border = 'rounded',
            height = 5,
          },
        }
      end,
    },

    {
      'cbochs/grapple.nvim',
      opts = {
        scope = 'git', -- default scope when creating a new tag
      },
      cmd = 'Grapple',
      keys = {
        {
          '<leader>gpt',
          function()
            require('grapple').toggle()
          end,
          desc = 'Grapple toggle tag',
        },
        {
          '<leader>gpT',
          function()
            require('grapple').toggle { scope = 'global' }
          end,
          desc = 'Grapple toggle global tag',
        },
        {
          '<leader>gpw',
          function()
            require('grapple').open_tags()
          end,
          desc = 'Grapple open tags window',
        },
        {
          '<leader>gpW',
          function()
            require('grapple').open_tags { scope = 'global' }
          end,
          desc = 'Grapple open global tags window',
        },
      },
      config = function()
        require('grapple').setup {
          win_opts = {
            border = 'rounded',
          },
        }
      end,
    },

    require 'plugins.configs.util.minimap',
    require 'plugins.configs.util.snacks',
  }
else
  return {}
end
