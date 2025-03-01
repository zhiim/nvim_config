if not vim.g.options.debug then
  return {}
end

return {
  'mfussenegger/nvim-dap',
  keys = {
    {
      '<F6>',
      function()
        require('dap').toggle_breakpoint()
      end,
      mode = { 'n', 'i' },
      desc = 'Debug toggle breakpoint',
    },
    {
      '<F7>',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      mode = { 'n', 'i' },
      desc = 'Debug set breakpoint',
    },
  },
  dependencies = {
    -- Installs the debug adapters for you
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    { 'mfussenegger/nvim-dap-python', lazy = true },

    -- show inline variable values
    {
      'theHamsta/nvim-dap-virtual-text',
      config = function()
        vim.api.nvim_set_hl(
          0,
          'NvimDapVirtualText',
          { link = 'DiagnosticSignHint' }
        )
        require('nvim-dap-virtual-text').setup {
          virt_text_pos = 'eol',
        }
      end,
    },

    {
      'LiadOz/nvim-dap-repl-highlights',
      config = function()
        require('nvim-dap-repl-highlights').setup()
        if not require('nvim-treesitter.parsers').has_parser 'dap_repl' then
          vim.cmd 'TSInstall dap_repl'
        end
      end,
    },

    -- completion for DAP REPL
    {
      'rcarriga/cmp-dap',
      enabled = vim.g.options.debug,
      config = function()
        if vim.g.options.cmp == 'nvim_cmp' then
          require('cmp').setup {
            enabled = function()
              return vim.bo.buftype ~= 'prompt'
                or require('cmp_dap').is_dap_buffer()
            end,
          }
          require('cmp').setup.filetype(
            { 'dap-repl', 'dapui_watches', 'dapui_hover' },
            {
              sources = {
                { name = 'dap' },
              },
            }
          )
        end
      end,
    },

    {
      'igorlfs/nvim-dap-view',
      enabled = vim.fn.has 'nvim-0.11' == 1,
      opts = {},
      keys = {
        {
          '<leader>dt',
          function()
            require('dap-view').toggle()
          end,
          { desc = 'DapView toggle' },
        },
      },
    },
  },
  config = function()
    local dap = require 'dap'
    dap.defaults.fallback.terminal_win_cmd = 'split new | resize'
      .. math.floor(vim.api.nvim_list_uis()[1].height * 0.4)

    -- auto close repl buffer
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'dap-repl',
      callback = function(args)
        vim.api.nvim_set_option_value('buflisted', false, { buf = args.buf })
      end,
    })

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},

      ensure_installed = {
        'python',
        'codelldb',
      },
    }

    vim.keymap.set(
      { 'n', 'i' },
      '<F5>',
      dap.continue,
      { desc = 'Debug start/continue' }
    )
    vim.keymap.set(
      { 'n', 'i' },
      '<F4>',
      dap.terminate,
      { desc = 'Debug terminate' }
    )
    vim.keymap.set(
      { 'n', 'i' },
      '<F1>',
      dap.step_into,
      { desc = 'Debug step into' }
    )
    vim.keymap.set(
      { 'n', 'i' },
      '<F2>',
      dap.step_over,
      { desc = 'Debug step over' }
    )
    vim.keymap.set(
      { 'n', 'i' },
      '<F3>',
      dap.step_out,
      { desc = 'Debug step out' }
    )

    -- re-define some DAP signs
    vim.fn.sign_define('DapStopped', {
      text = '󰁕 ',
      texthl = 'DiagnosticWarn',
      linehl = 'DapStoppedLine',
      numhl = 'DapStoppedLine',
    })
    vim.fn.sign_define(
      'DapBreakpoint',
      { text = ' ', texthl = 'DiagnosticInfo', linehl = '', numhl = '' }
    )
    vim.fn.sign_define(
      'DapBreakpointCondition',
      { text = ' ', texthl = 'DiagnosticInfo', linehl = '', numhl = '' }
    )
    vim.fn.sign_define(
      'DapBreakpointRejected',
      { text = ' ', texthl = 'DiagnosticInfo', linehl = '', numhl = '' }
    )
    vim.fn.sign_define(
      'DapLogPoint',
      { text = '.>', texthl = 'DiagnosticInfo', linehl = '', numhl = '' }
    )

    local widgets = require 'dap.ui.widgets'

    -- key mappings for DAP
    vim.keymap.set({ 'n' }, '<leader>dh', function()
      widgets.hover()
    end, { desc = 'Debug hover' })
    vim.keymap.set({ 'n' }, '<leader>ds', function()
      widgets.centered_float(widgets.scopes)
    end, { desc = 'Debug toggle scopes widget' })
    vim.keymap.set({ 'n' }, '<leader>df', function()
      widgets.centered_float(widgets.frames)
    end, { desc = 'Debug toggle frames widget' })
    vim.keymap.set({ 'n' }, '<leader>dr', function()
      require('dap.repl').toggle(
        { width = math.floor(vim.api.nvim_list_uis()[1].width * 0.4) },
        'vsplit'
      )
    end, { desc = 'Debug toggle repl widget' })

    if vim.fn.has 'win32' == 0 then
      require('dap-python').setup(
        vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
      )
    else
      require('dap-python').setup(
        vim.fn.stdpath 'data'
          .. '/mason/packages/debugpy/venv/Scripts/python.exe'
      )
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
