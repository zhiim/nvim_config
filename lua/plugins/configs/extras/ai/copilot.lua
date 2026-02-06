local ai_opts = vim.g.options.plugins.ai

return {
  'zbirenbaum/copilot.lua',
  enabled = vim.fn.has 'nvim-0.11' and ai_opts.components.copilot
    or ai_opts.enable_all,
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
