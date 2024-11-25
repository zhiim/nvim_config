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
      '<leader>ccs',
      '<cmd>CodeCompanionChat Add<CR>',
      desc = 'Add Selected to CodeCompanion Chat',
      mode = { 'n', 'v' },
    },
  },
  config = function()
    require('codecompanion').setup {
      display = {
        chat = {
          render_headers = false,
        },
      },
      strategies = {
        chat = {
          adapter = 'gemini',
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
          proxy = vim.g.options.proxy,
        },
      },
    }
  end,
}
