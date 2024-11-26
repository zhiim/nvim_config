return {
  'olimorris/codecompanion.nvim',
  cmd = { 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanion' },
  keys = {
    {
      '<leader>cca',
      '<cmd>CodeCompanionActions<CR>',
      desc = 'Open the CodeCompanion Action Palette',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccc',
      '<cmd>CodeCompanionChat Toggle<CR>',
      desc = 'Toggle the CodeCompanion Chat',
      mode = { 'n', 'v' },
    },
    {
      'q',
      function()
        if vim.api.nvim_get_option_value('filetype', { buf = 0 }) == 'codecompanion' then
          vim.cmd 'CodeCompanionChat Toggle'
        end
      end,
      desc = 'Toggle the CodeCompanion Chat',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccs',
      ':CodeCompanionChat Add<CR>',
      desc = 'Add Selected to CodeCompanion Chat',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccp',
      '<cmd>CodeCompanion<CR>',
      desc = 'CodeCompanion',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccm',
      function()
        vim.ui.input({ prompt = 'Select a model: ' }, function(input)
          if input then
            vim.cmd('CodeCompanionChat ' .. input)
          end
        end)
      end,
      desc = 'CodeCompanionChat with a Selected Model',
      mode = { 'n', 'v' },
    },
  },
  config = function()
    require('codecompanion').setup {
      display = {
        chat = {
          render_headers = false,
          show_settings = true,
          window = {
            width = 0.3,
          },
        },
      },
      strategies = {
        chat = {
          adapter = 'gemini',
          keymaps = {
            close = {
              modes = {
                n = '<C-x>',
                i = '<C-x>',
              },
              index = 3,
              callback = 'keymaps.close',
              description = 'Close Chat',
            },
            stop = {
              modes = {
                n = '<C-c>',
              },
              index = 4,
              callback = 'keymaps.stop',
              description = 'Stop Request',
            },
          },
        },
        inline = {
          adapter = 'gemini',
        },
      },
      adapters = {
        gemini = function()
          return require('codecompanion.adapters').extend('gemini', {
            env = {
              api_key = vim.g.options.gemini_api_key,
            },
          })
        end,
        opts = {
          language = 'Chinese',
          proxy = vim.g.options.proxy,
        },
      },
    }
  end,
}
