return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
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
      '<leader>ss',
      builtin.builtin,
      { desc = 'Telescope search telescope sections' }
    )
    vim.keymap.set(
      'n',
      '<leader>sw',
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
      '<leader>s.',
      builtin.oldfiles,
      { desc = 'Telescope search recent files' }
    )
    vim.keymap.set(
      'n',
      '<leader>sb',
      '<cmd>Telescope scope buffers<cr>',
      { desc = 'Telescope find existing buffers' }
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
  end,
}
