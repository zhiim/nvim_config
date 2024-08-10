if not vim.g.use_copilot then
  return {}
end
return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    cmd = {
      'CopilotChatOpen',
      'CopilotChatClose',
      'CopilotChatToggle',
    },
    dependencies = {
      {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        event = 'InsertEnter',
        config = function()
          require('copilot').setup {
            suggestion = { enabled = false },
            panel = { enabled = false },
          }
        end,
      },
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
