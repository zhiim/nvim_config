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
          ft_ignore = { 'codecompanion', 'copilot-chat' },
          segments = {
            -- fold sign
            { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
            -- diagnostic sign
            {
              sign = { namespace = { 'diagnostic*' }, maxwidth = 1, colwidth = 1, auto = true },
              click = 'v:lua.ScSa',
            },
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

    {
      'kevinhwang91/nvim-ufo',
      event = 'BufRead',
      dependencies = 'kevinhwang91/promise-async',
      enabled = vim.fn.has 'nvim-0.7.2',
      config = function()
        vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep:│,foldclose:]]
        vim.o.foldcolumn = '1'
        vim.o.foldlevel = 99 -- Using ufo provider need a large value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Using ufo provider need remap `zR` and `zM`
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

        ---@param bufnr number
        ---@return Promise
        local function customizeSelector(bufnr)
          local function handleFallbackException(err, providerName)
            if type(err) == 'string' and err:match 'UfoFallbackException' then
              return require('ufo').getFolds(bufnr, providerName)
            else
              return require('promise').reject(err)
            end
          end

          return require('ufo')
            .getFolds(bufnr, 'lsp')
            :catch(function(err)
              return handleFallbackException(err, 'treesitter')
            end)
            :catch(function(err)
              return handleFallbackException(err, 'indent')
            end)
        end

        require('ufo').setup {
          provider_selector = function(bufnr, filetype, buftype)
            return customizeSelector
          end,
        }
        -- require('ufo').setup {
        --
        --   provider_selector = function(bufnr, filetype, buftype)
        --     return { 'treesitter', 'indent' }
        --   end,
        -- }
      end,
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
