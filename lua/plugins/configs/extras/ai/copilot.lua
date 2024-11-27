return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    keys = {
      {
        '<leader>cpt',
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
        '<leader>cpf',
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
        '<leader>cpi',
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
        '<leader>cps',
        function()
          require('CopilotChat').select_model()
        end,
        mode = 'n',
        desc = 'CopilotChat Select Models',
      },
      {
        '<leader>cpq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = 'CopilotChat Quick Chat',
      },
      {
        '<leader>cpm',
        function()
          vim.notify(require('CopilotChat').config.model, vim.log.levels.INFO, { title = 'CopilotChat Model Info' })
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
          vim.keymap.set('n', '<leader>cpo', function()
            require('copilot.panel').open { position = 'bottom' }
          end, { desc = 'Copilot Open Panel' })
        end,
      },
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    config = function()
      local copilot_config = {
        highlight_headers = false,
        separator = '---',
        error_header = '> [!ERROR] Error',
        debug = true,
        proxy = vim.g.options.proxy,
        mappings = {
          complete = {
            insert = '',
          },
        },
      }
      require('CopilotChat').setup(copilot_config)
    end,
  },
}
