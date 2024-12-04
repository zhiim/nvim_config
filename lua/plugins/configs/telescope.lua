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
    local normal = get_hl 'Normal'
    local fg, bg = normal.fg, normal.bg
    local bg_alt = get_hl('CursorLine').bg
    local green = get_hl('String').fg
    local red = get_hl('Error').fg
    -- return a table of highlights for telescope based on
    -- colors gotten from highlight groups
    vim.api.nvim_set_hl(0, 'TelescopeBorder', { fg = bg_alt, bg = bg })
    vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = bg })
    vim.api.nvim_set_hl(0, 'TelescopePreviewBorder', { fg = bg, bg = bg })
    vim.api.nvim_set_hl(0, 'TelescopePreviewNormal', { bg = bg })
    vim.api.nvim_set_hl(0, 'TelescopePreviewTitle', { fg = bg, bg = green })
    vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { fg = bg_alt, bg = bg_alt })
    vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { fg = fg, bg = bg_alt })
    vim.api.nvim_set_hl(0, 'TelescopePromptPrefix', { fg = red, bg = bg_alt })
    vim.api.nvim_set_hl(0, 'TelescopePromptTitle', { fg = bg, bg = red })
    vim.api.nvim_set_hl(0, 'TelescopeResultsBorder', { fg = bg, bg = bg })
    vim.api.nvim_set_hl(0, 'TelescopeResultsNormal', { bg = bg })
    vim.api.nvim_set_hl(0, 'TelescopeResultsTitle', { fg = bg, bg = bg })

    require('telescope').setup {

      defaults = {
        prompt_prefix = '   ',
        sorting_strategy = 'ascending',
        layout_config = {
          horizontal = {
            prompt_position = 'top',
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
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
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', '<cmd>Telescope scope buffers<cr>', { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>su', '<cmd>Telescope undo<cr>')

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
