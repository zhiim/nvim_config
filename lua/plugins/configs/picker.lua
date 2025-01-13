local picker = { -- Fuzzy Finder (files, lsp, etc)
  telescope = {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'debugloop/telescope-undo.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        build = 'make',

        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      require('telescope').setup {

        defaults = {
          prompt_prefix = '   ',
          sorting_strategy = 'ascending',
          layout_config = {
            horizontal = {
              prompt_position = 'top',
            },
          },
          mappings = {
            n = { ['q'] = require('telescope.actions').close },
          },
        },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          ['undo'] = {},
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'undo')
      pcall(require('telescope').load_extension, 'scope')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set(
        'n',
        '<leader>sh',
        builtin.help_tags,
        { desc = 'Telescope search help' }
      )
      vim.keymap.set(
        'n',
        '<leader>sk',
        builtin.keymaps,
        { desc = 'Telescope search keymaps' }
      )
      vim.keymap.set(
        'n',
        '<leader>sf',
        builtin.find_files,
        { desc = 'Telescope search files' }
      )
      vim.keymap.set(
        'n',
        '<leader>si',
        builtin.builtin,
        { desc = 'Telescope search telescope builtins items' }
      )
      vim.keymap.set(
        'n',
        '<leader>s#',
        builtin.grep_string,
        { desc = 'Telescope search current word' }
      )
      vim.keymap.set(
        'n',
        '<leader>sg',
        builtin.live_grep,
        { desc = 'Telescope search by grep' }
      )
      vim.keymap.set(
        'n',
        '<leader>sd',
        builtin.diagnostics,
        { desc = 'Telescope search diagnostics' }
      )
      vim.keymap.set(
        'n',
        '<leader>sr',
        builtin.resume,
        { desc = 'Telescope search resume' }
      )
      vim.keymap.set(
        'n',
        '<leader>so',
        builtin.oldfiles,
        { desc = 'Telescope search recent files' }
      )
      vim.keymap.set(
        'n',
        '<leader>sb',
        '<cmd>Telescope scope buffers<cr>',
        { desc = 'Telescope search existing buffers' }
      )
      vim.keymap.set(
        'n',
        '<leader>su',
        '<cmd>Telescope undo<cr>',
        { desc = 'Telescope search undo history' }
      )
      vim.keymap.set(
        'n',
        '<leader>s\\',
        builtin.highlights,
        { desc = 'Telescope search highlights' }
      )

      vim.keymap.set('n', '<leader>sl', function()
        builtin.current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown {
            -- winblend = 10,
            previewer = false,
          }
        )
      end, { desc = 'Telescope search in current buffer fuzzily ' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = 'Telescope search in open files' })

      vim.keymap.set(
        'n',
        '<leader>st',
        builtin.tags,
        { desc = 'Telescope search tags' }
      )

      vim.keymap.set(
        'n',
        '<leader>sm',
        builtin.commands,
        { desc = 'Telescope search commands' }
      )

      vim.keymap.set(
        'n',
        '<leader>sj',
        builtin.jumplist,
        { desc = 'Telescope search jumps' }
      )

      vim.keymap.set(
        'n',
        '<leader>ss',
        builtin.lsp_document_symbols,
        { desc = 'Telescope search document symbols' }
      )
    end,
  },

  fzf_lua = {
    'ibhagwan/fzf-lua',
    event = 'VimEnter',
    config = function()
      local fzf_lua = require 'fzf-lua'
      local actions = require('fzf-lua').actions

      fzf_lua.setup {
        'default-title',

        fzf_colors = true, -- generate fzf colorscheme from Neovim colorscheme

        winopts = {
          backdrop = 180,
          width = 0.85,
          height = 0.85,
          row = 0.5,
          col = 0.5,
          preview = {
            scrollchars = { '┃', '' },
          },
        },

        keymap = {
          builtin = {
            true, -- inherit defaults
            ['<Esc>'] = 'hide',
            ['<C-f>'] = 'preview-page-down',
            ['<C-b>'] = 'preview-page-up',
          },
        },

        files = {
          actions = {
            ['alt-i'] = { actions.toggle_ignore },
            ['alt-h'] = { actions.toggle_hidden },
          },
        },

        grep = {
          actions = {
            ['alt-i'] = { actions.toggle_ignore },
            ['alt-h'] = { actions.toggle_hidden },
          },
        },
      }

      require('fzf-lua').register_ui_select(function(_, items)
        local min_h, max_h = 0.30, 0.70
        local h = (#items + 4) / vim.o.lines
        if h < min_h then
          h = min_h
        elseif h > max_h then
          h = max_h
        end
        return {
          winopts = { height = h, width = 0.60, row = 0.50 },
          fzf_opts = { ['--with-nth'] = '2..' },
        }
      end)

      vim.keymap.set(
        'n',
        '<leader>sh',
        '<cmd>FzfLua help_tags<cr>',
        { desc = 'FzfLua search help' }
      )
      vim.keymap.set(
        'n',
        '<leader>sk',
        '<cmd>FzfLua keymaps<cr>',
        { desc = 'FzfLua search keymaps' }
      )
      vim.keymap.set(
        'n',
        '<leader>sf',
        '<cmd>FzfLua files<cr>',
        { desc = 'FzfLua search files' }
      )
      vim.keymap.set(
        'n',
        '<leader>si',
        '<cmd>FzfLua builtin<cr>',
        { desc = 'FzfLua search fzflua builtin items' }
      )
      vim.keymap.set(
        'n',
        '<leader>s#',
        '<cmd>FzfLua grep_cword<cr>',
        { desc = 'FzfLua search current word' }
      )
      vim.keymap.set(
        'n',
        '<leader>sg',
        '<cmd>FzfLua live_grep<cr>',
        { desc = 'FzfLua search by grep' }
      )
      vim.keymap.set(
        'n',
        '<leader>sd',
        '<cmd>FzfLua diagnostics_workspace<cr>',
        { desc = 'FzfLua search diagnostics' }
      )
      vim.keymap.set(
        'n',
        '<leader>sr',
        '<cmd>FzfLua resume<cr>',
        { desc = 'FzfLua search resume' }
      )
      vim.keymap.set(
        'n',
        '<leader>so',
        '<cmd>FzfLua oldfiles<cr>',
        { desc = 'FzfLua search recent files' }
      )
      vim.keymap.set(
        'n',
        '<leader>sb',
        '<cmd>FzfLua buffers<cr>',
        { desc = 'FzfLua search existing buffers' }
      )
      vim.keymap.set(
        'n',
        '<leader>s\\',
        '<cmd>FzfLua highlights<cr>',
        { desc = 'FzfLua search highlights' }
      )

      vim.keymap.set(
        'n',
        '<leader>sl',
        '<cmd>FzfLua lgrep_curbuf<cr>',
        { desc = 'FzfLua search in current buffer fuzzily ' }
      )

      vim.keymap.set(
        'n',
        '<leader>s/',
        '<cmd>FzfLua lines<cr>',
        { desc = 'FzfLua search in open files' }
      )

      vim.keymap.set(
        'v',
        '<leader>sw',
        '<cmd>FzfLua grep_visual<cr>',
        { desc = 'FzfLua search visual selection' }
      )

      vim.keymap.set(
        'n',
        '<leader>st',
        '<cmd>FzfLua tags_grep<cr>',
        { desc = 'FzfLua search tags' }
      )

      vim.keymap.set(
        'n',
        '<leader>sm',
        '<cmd>FzfLua commands<cr>',
        { desc = 'FzfLua search commands' }
      )

      vim.keymap.set(
        'n',
        '<leader>sj',
        '<cmd>FzfLua jumps<cr>',
        { desc = 'FzfLua search jumps' }
      )

      vim.keymap.set(
        'n',
        '<leader>ss',
        '<cmd>FzfLua lsp_document_symbols<cr>',
        { desc = 'FzfLua search document symbols' }
      )
    end,
  },
}

return picker[vim.g.options.picker]
