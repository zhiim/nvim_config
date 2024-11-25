if vim.g.options.enhance then
  return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            {
              icon = '  ',
              key = 's',
              desc = 'Read Saved Session',
              action = ":lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Leader>msr', true, false, true), 'm', true)",
            },
            { icon = '  ', key = 'r', desc = 'Recent Files', action = ':Telescope oldfiles' },
            { icon = '  ', key = 'f', desc = 'Find File', action = ':Telescope find_files' },
            { icon = '  ', key = 'w', desc = 'Find Word', action = ':Telescope live_grep' },
            { icon = '  ', key = 'e', desc = 'New Files', action = ':ene | startinsert' },
            {
              icon = '  ',
              key = 'q',
              desc = 'Quit',
              action = function()
                vim.api.nvim_input ':qa'
              end,
            },
          },
          header = vim.g.logo,
        },
        sections = {
          { section = 'header' },
          { section = 'keys', gap = 1, padding = 1 },
          { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
          { section = 'startup' },
        },
      },
      notifier = {
        timeout = 3000,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      {
        '<leader>bd',
        function()
          Snacks.bufdelete()
        end,
        desc = 'Delete Buffer',
      },
      {
        '<leader>lgo',
        function()
          Snacks.lazygit()
        end,
        desc = 'Lazygit Open',
      },
      {
        '<leader>lgf',
        function()
          Snacks.lazygit.log_file()
        end,
        desc = 'Lazygit Current File History',
      },
      {
        '<leader>lgl',
        function()
          Snacks.lazygit.log()
        end,
        desc = 'Lazygit Log (cwd)',
      },
      {
        '<leader>Rn',
        function()
          Snacks.rename.rename_file()
        end,
        desc = 'Rename File',
      },
      {
        ']]',
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = 'Next Reference',
        mode = { 'n', 't' },
      },
      {
        '[[',
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = 'Prev Reference',
        mode = { 'n', 't' },
      },
      {
        '<leader>nh',
        function()
          Snacks.notifier.show_history()
        end,
        desc = 'Notification History',
        mode = { 'n', 't' },
      },
      {
        '<leader>nu',
        function()
          Snacks.notifier.hide()
        end,
        desc = 'Dismiss All Notifications',
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command
        end,
      })
    end,
  }
else
  return {}
end
