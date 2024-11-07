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
              layout = 'vertical',
              title = 'Copilot Chat',
              width = 0.3,
            },
          }
        end,
        mode = { 'n', 'v' },
        desc = 'CopilotChat Toggle',
      },
      {
        '<leader>cf',
        function()
          require('CopilotChat').toggle {
            window = {
              layout = 'float',
              title = 'Copilot Chat',
              width = 0.8,
              height = 0.8,
            },
          }
        end,
        mode = { 'n', 'v' },
        desc = 'CopilotChat Float Windows',
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
        mode = { 'n', 'v' },
        desc = 'CopilotChat Inline Chat',
      },
      {
        '<leader>cs',
        function()
          require('CopilotChat').select_model()
        end,
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
        '<leader>cm',
        function()
          print(require('CopilotChat').config.model)
        end,
        mode = 'n',
        desc = 'CopilotChat Model Info',
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
            require('copilot.panel').open { position = 'bottom' }
          end, { desc = 'Copilot Open Panel' })
        end,
      },
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    config = function()
      local copilot_config = {
        debug = true,
        mappings = {
          complete = {
            insert = '',
          },
        },
      }
      if vim.g.proxy ~= nil then
        copilot_config.proxy = vim.g.proxy
      end
      require('CopilotChat').setup(copilot_config)
      require('CopilotChat.integrations.cmp').setup()
    end,
  },
}
