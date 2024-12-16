return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
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
        desc = 'Copilot toggle chat',
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
        desc = 'Copilot chat in float windows',
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
        desc = 'Copilot inline chat',
      },
      {
        '<leader>cps',
        function()
          require('CopilotChat').select_model()
        end,
        mode = 'n',
        desc = 'Copilot select chat models',
      },
      {
        '<leader>cpq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(
              input,
              { selection = require('CopilotChat.select').buffer }
            )
          end
        end,
        desc = 'Copilot quick chat',
      },
      {
        '<leader>cpm',
        function()
          vim.notify(
            require('CopilotChat').config.model,
            vim.log.levels.INFO,
            { title = 'CopilotChat Model Info' }
          )
        end,
        mode = 'n',
        desc = 'Copilot chat model info',
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
          end, { desc = 'Copilot open panel' })
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
          reset = {
            normal = '<A-r>',
            insert = '<A-r>',
          },
        },
        window = {
          border = 'rounded', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
        },
      }
      require('CopilotChat').setup(copilot_config)
    end,
  },
}
