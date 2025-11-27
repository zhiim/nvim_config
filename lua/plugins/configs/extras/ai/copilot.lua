return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = '<M-y>',
        },
      },
    }
    vim.keymap.set('n', '<leader>cp', function()
      require('copilot.panel').open { position = 'bottom' }
    end, { desc = 'Copilot open panel' })
  end,
}
