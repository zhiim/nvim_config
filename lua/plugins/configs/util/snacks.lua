return {
  'folke/snacks.nvim',
  priority = 1000,
  enabled = vim.g.options.enhance,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          {
            icon = '  ',
            key = 's',
            desc = 'Read Saved Session',
            action = ":lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Leader>rsr', true, false, true), 'm', true)",
          },
          { icon = '  ', key = 'r', desc = 'Recent Files', action = ':Telescope oldfiles' },
          { icon = '  ', key = 'f', desc = 'Find File', action = ':Telescope find_files' },
          { icon = '  ', key = 'w', desc = 'Find Word', action = ':Telescope live_grep' },
          { icon = '  ', key = 'e', desc = 'New Files', action = ':ene | startinsert' },
          {
            icon = '  ',
            key = 'q',
            desc = 'Quit',
            action = function()
              vim.api.nvim_input ':qa<cr>'
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
    statuscolumn = { enabled = false },
    words = { enabled = true },
  },
  keys = {
    {
      '<leader>lg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
      mode = 'n',
    },
    {
      '<leader>Rn',
      function()
        Snacks.rename.rename_file()
      end,
      desc = 'Rename File',
      mode = 'n',
    },
    {
      ']]',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next Reference',
      mode = 'n',
    },
    {
      '[[',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Prev Reference',
      mode = 'n',
    },
    {
      '<leader>nh',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification history',
      mode = 'n',
    },
    {
      '<leader>nu',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Notification dismiss all ',
      mode = 'n',
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

        Snacks.toggle.option('relativenumber', { off = false, on = true }):map '<leader>tn'
      end,
    })
  end,
}
