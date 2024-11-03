if not vim.g.use_copilot then
  return {}
end
return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    cmd = 'CopilotChatModels',
    keys = {
      {
        '<leader>ct',
        function()
          require('CopilotChat').toggle()
        end,
        mode = 'n',
        desc = 'CopilotChat Toggle',
      },
      {
        '<leader>cs',
        '<cmd>CopilotChatModels<cr>',
        mode = 'n',
        desc = 'CopilotChat Select Models',
      },
      {
        '<leader>cq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = 'CopilotChat Quick Chat',
      },
      {
        '<leader>ci',
        function()
          require('CopilotChat').toggle {
            window = {
              layout = 'float',
              relative = 'cursor',
              width = 1,
              height = 0.4,
              row = 1,
            },
          }
        end,
        mode = 'n',
        desc = 'CopilotChat Inline Chat',
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
          vim.keymap.set('n', '<leader>co', function()
            require('copilot.panel').open()
          end, { desc = 'Open Copilot Open Panel' })
        end,
      },
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    config = function()
      require('CopilotChat').setup {
        debug = true,
        mappings = {
          complete = {
            insert = '',
          },
        },
      }
      require('CopilotChat.integrations.cmp').setup()
    end,
  },
}
