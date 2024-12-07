return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'debugloop/telescope-undo.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
  },
  config = function()
    -- highlight group
    local get_hl = require('utils.util').get_hl
    local bg = get_hl('Normal').bg
    local colors = require('utils.util').get_palette()
    local preview_title = colors.green
    local prompt_title_bg = colors.blue
    local result_title_bg = colors.orange
    -- return a table of highlights for telescope based on
    -- colors gotten from highlight groups
    vim.api.nvim_set_hl(0, 'TelescopeBorder', { link = 'FloatBorder' })
    vim.api.nvim_set_hl(0, 'TelescopeNormal', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(0, 'TelescopePreviewBorder', { link = 'FloatBorder' })
    vim.api.nvim_set_hl(0, 'TelescopePreviewNormal', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(0, 'TelescopePreviewTitle', { fg = bg, bg = preview_title })
    vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { link = 'FloatBorder' })
    vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(0, 'TelescopePromptPrefix', { fg = prompt_title_bg, bg = bg })
    vim.api.nvim_set_hl(0, 'TelescopePromptTitle', { fg = bg, bg = prompt_title_bg })
    vim.api.nvim_set_hl(0, 'TelescopeResultsBorder', { link = 'FloatBorder' })
    vim.api.nvim_set_hl(0, 'TelescopeResultsNormal', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(0, 'TelescopeResultsTitle', { fg = bg, bg = result_title_bg })

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
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope search help' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Telescope search keymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Telescope search files' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'Telescope search telescope sections' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Telescope search current word' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Telescope search by grep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Telescope search diagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Telescope search resume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Telescope search recent files' })
    vim.keymap.set('n', '<leader><leader>', '<cmd>Telescope scope buffers<cr>', { desc = 'Telescope find existing buffers' })
    vim.keymap.set('n', '<leader>su', '<cmd>Telescope undo<cr>', { desc = 'Telescope search undo history' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        -- winblend = 10,
        previewer = false,
      })
    end, { desc = 'Telescope search in current buffer fuzzily ' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = 'Telescope search in open files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = 'Telescope search neovim files' })
  end,
}
