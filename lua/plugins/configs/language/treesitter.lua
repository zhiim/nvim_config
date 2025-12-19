return { -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ensure_installed = {
        'bash',
        'c',
        'cpp',
        'python',
        'diff',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'vim',
        'vimdoc',
        'yaml',
        'json',
        'toml',
      }
      local group =
        vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

      local function treesitter_enable(filetype)
        local WAIT_TIME = 1000 * 30 -- 30 seconds
        require('nvim-treesitter').install(filetype):wait(WAIT_TIME)
        local lang = vim.treesitter.language.get_lang(filetype)

        local ok = pcall(vim.treesitter.language.add, lang)
        if not ok then
          return
        end

        if lang ~= nil then
          vim.api.nvim_create_autocmd('FileType', {
            group = group,
            desc = 'Enable Treesitter features for ' .. lang,
            pattern = vim.treesitter.language.get_filetypes(lang),
            callback = function()
              if vim.treesitter.query.get(lang, 'highlights') then
                vim.treesitter.start()
              end
              if vim.treesitter.query.get(lang, 'indents') then
                vim.bo.indentexpr =
                  "v:lua.require('nvim-treesitter').indentexpr()"
              end
              if vim.treesitter.query.get(lang, 'folds') then
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                vim.wo.foldmethod = 'expr'
              end
            end,
          })
        end
      end

      for _, lang in ipairs(ensure_installed) do
        treesitter_enable(lang)
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    init = function()
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      vim.g.no_plugin_maps = true
    end,
    config = function()
      vim.keymap.set({ 'x', 'o' }, 'am', function()
        require('nvim-treesitter-textobjects.select').select_textobject(
          '@function.outer',
          'textobjects'
        )
      end, { desc = 'Select around function' })
      vim.keymap.set({ 'x', 'o' }, 'im', function()
        require('nvim-treesitter-textobjects.select').select_textobject(
          '@function.inner',
          'textobjects'
        )
      end, { desc = 'Select inner function' })
      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        require('nvim-treesitter-textobjects.select').select_textobject(
          '@class.outer',
          'textobjects'
        )
      end, { desc = 'Select around class' })
      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        require('nvim-treesitter-textobjects.select').select_textobject(
          '@class.inner',
          'textobjects'
        )
      end, { desc = 'Select inner class' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
        require('nvim-treesitter-textobjects.move').goto_next_start(
          '@function.outer',
          'textobjects'
        )
      end, { desc = 'Go to next function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
        require('nvim-treesitter-textobjects.move').goto_next_start(
          '@class.outer',
          'textobjects'
        )
      end, { desc = 'Go to next class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']o', function()
        require('nvim-treesitter-textobjects.move').goto_next_start(
          { '@loop.inner', '@loop.outer' },
          'textobjects'
        )
      end, { desc = 'Go to next loop start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
        require('nvim-treesitter-textobjects.move').goto_next_start(
          '@local.scope',
          'locals'
        )
      end, { desc = 'Go to next local scope start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']z', function()
        require('nvim-treesitter-textobjects.move').goto_next_start(
          '@fold',
          'folds'
        )
      end, { desc = 'Go to next fold start' })

      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start(
          '@function.outer',
          'textobjects'
        )
      end, { desc = 'Go to previous function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start(
          '@class.outer',
          'textobjects'
        )
      end, { desc = 'Go to previous class start' })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {
        max_lines = 3,
      }
      vim.keymap.set('n', '[c', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true })
    end,
  },
}
