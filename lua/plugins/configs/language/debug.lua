if not vim.g.options.debug then
  return {}
end

return {
  'mfussenegger/nvim-dap',
  keys = {
    {
      '<F7>',
      function()
        require('dap').toggle_breakpoint()
      end,
      mode = { 'n', 'i' },
      desc = 'Debug toggle breakpoint',
    },
    {
      '<F8>',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      mode = { 'n', 'i' },
      desc = 'Debug set breakpoint',
    },
  },
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    { 'mfussenegger/nvim-dap-python', lazy = true },

    -- show inline variable values
    {
      'theHamsta/nvim-dap-virtual-text',
      config = function()
        require('nvim-dap-virtual-text').setup {
          virt_text_pos = 'eol',
        }
      end,
    },

    -- completion for DAP REPL
    {
      'rcarriga/cmp-dap',
      config = function()
        require('cmp').setup {
          enabled = function()
            return vim.bo.buftype ~= 'prompt' or require('cmp_dap').is_dap_buffer()
          end,
        }

        require('cmp').setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
          sources = {
            { name = 'dap' },
          },
        })
      end,
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- auto close repl buffer
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'dap-repl',
      callback = function(args)
        vim.api.nvim_set_option_value('buflisted', false, { buf = args.buf })
      end,
    })

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers, see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'python',
        'codelldb',
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set({ 'n', 'i' }, '<F5>', dap.continue, { desc = 'Debug start/continue' })
    vim.keymap.set({ 'n', 'i' }, '<F4>', dap.terminate, { desc = 'Debug terminate' })
    vim.keymap.set({ 'n', 'i' }, '<F1>', dap.step_into, { desc = 'Debug step into' })
    vim.keymap.set({ 'n', 'i' }, '<F2>', dap.step_over, { desc = 'Debug step over' })
    vim.keymap.set({ 'n', 'i' }, '<F3>', dap.step_out, { desc = 'Debug step out' })
    -- vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    -- vim.keymap.set('n', '<leader>B', function()
    --   dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    -- end, { desc = 'Debug: Set Breakpoint' })

    local dapui_opt = {}
    dapui.setup(dapui_opt)

    -- re-define some DAP signs
    vim.fn.sign_define('DapStopped', { text = '󰁕 ', texthl = 'DiagnosticWarn', linehl = 'DapStoppedLine', numhl = 'DapStoppedLine' })
    vim.fn.sign_define('DapBreakpoint', { text = ' ', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = ' ', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointRejected', { text = ' ', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })
    vim.fn.sign_define('DapLogPoint', { text = '.>', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })

    -- key mappings for DAP UI
    vim.keymap.set({ 'n', 'i' }, '<F6>', function()
      dapui.toggle()
    end, { desc = 'Debug toggle debug UI' })
    vim.keymap.set({ 'n' }, '<leader>due', function()
      dapui.eval()
    end, { desc = 'Debug eval' })
    vim.keymap.set({ 'n' }, '<leader>duE', function()
      local expr = vim.fn.input 'Expression: '
      dapui.eval(expr)
    end, { desc = 'Debug eval expression' })
    vim.keymap.set({ 'n' }, '<leader>duf', function()
      dapui.float_element()
    end, { desc = 'Debug float element' })

    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open {}
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close {}
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close {}
    end

    if vim.fn.has 'win32' == 0 then
      require('dap-python').setup(vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python')
    else
      require('dap-python').setup(vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/Scripts/python.exe')
    end
    table.insert(require('dap').configurations.python, {
      type = 'python',
      request = 'launch',
      name = 'Custom: debug outside',
      program = '${file}',
      justMyCode = false,
      -- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
    })
  end,
}
