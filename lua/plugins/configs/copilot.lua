if not vim.g.use_copilot then
  return {}
end
return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    keys = {
      {
        '<leader>ct',
        function()
          require('CopilotChat').toggle {
            window = {
              layout = 'float',
              title = 'Copilot Chat',
            },
          }
        end,
        mode = 'n',
        desc = 'Copilot Chat Toggle ',
      },
    },
    dependencies = {
      {
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
            require('copilot.panel').open()
          end, { desc = 'Open Copilot Panel' })
        end,
      },
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      -- See Configuration section for rest
      window = {
        layout = 'float', -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.8, -- fractional width of parent, or absolute width in columns when > 1
        height = 0.8, -- fractional height of parent, or absolute height in rows when > 1
        -- Options below only apply to floating windows
        relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
        border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
        row = nil, -- row position of the window, default is centered
        col = nil, -- column position of the window, default is centered
        title = 'Copilot Chat', -- title of chat window
        footer = nil, -- footer of chat window
        zindex = 1, -- determines if window is on top or below other floating windows
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
