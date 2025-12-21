local cmd_row = math.floor(vim.api.nvim_list_uis()[1].height) * 0.3

return {
  'folke/snacks.nvim',
  priority = 1000,
  enabled = vim.g.options.mode == 'IDE',
  lazy = false,
  opts = {
    scroll = {
      animate = {
        duration = { step = 10, total = 250 },
        easing = 'linear',
      },
      -- what buffers to animate
      filter = function(buf)
        local var_set = vim.g.snacks_scroll ~= false
          and vim.b[buf].snacks_scroll ~= false
        local bt = vim.bo[buf].buftype ~= 'terminal'
        local ft = vim.bo[buf].filetype ~= 'grug-far'
        return var_set and bt and ft
      end,
    },
    input = {
      row = cmd_row,
    },
    bigfile = { enabled = true },
    image = {
      doc = {
        enabled = false,
      },
    },
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
          {
            icon = '  ',
            key = 'r',
            desc = 'Recent Files',
            action = ":lua Snacks.dashboard.pick('oldfiles')",
          },
          {
            icon = '  ',
            key = 'f',
            desc = 'Find File',
            action = ":lua Snacks.dashboard.pick('files')",
          },
          {
            icon = '  ',
            key = 'w',
            desc = 'Find Word',
            action = ":lua Snacks.dashboard.pick('live_grep')",
          },
          {
            icon = '  ',
            key = 'e',
            desc = 'New Files',
            action = ':ene | startinsert',
          },
          {
            icon = '  ',
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
        {
          icon = ' ',
          title = 'Recent Files',
          section = 'recent_files',
          indent = 2,
          padding = 1,
        },
        {
          icon = ' ',
          title = 'Projects',
          section = 'projects',
          indent = 2,
          padding = 1,
        },
        { section = 'startup', icon = '󱐋 ' },
      },
    },
    indent = {
      indent = {
        hl = {
          'ForeRed',
          'ForeYellow',
          'ForeBlue',
          'ForeOrange',
          'ForeGreen',
          'ForePurple',
          'ForeCyan',
        },
      },
    },
    notifier = {
      timeout = 3000,
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = false },
    words = { enabled = true },
    scope = { enabled = true },
  },
  keys = {
    {
      '<leader>ng',
      function()
        Snacks.lazygit()
      end,
      desc = 'Snacks Lazygit',
      mode = 'n',
    },
    {
      '<leader>nr',
      function()
        Snacks.rename.rename_file()
      end,
      desc = 'Snacks rename File',
      mode = 'n',
    },
    {
      ']]',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Snacks next Reference',
      mode = 'n',
    },
    {
      '[[',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Snacks prev Reference',
      mode = 'n',
    },
    {
      '<leader>nnh',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Snacks notification history',
      mode = 'n',
    },
    {
      '<leader>nnu',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Snacks notification dismiss all ',
      mode = 'n',
    },
    {
      '<leader>nd',
      function()
        if Snacks.dim.enabled then
          Snacks.dim.disable()
        else
          Snacks.dim.enable()
        end
      end,
      mode = 'n',
      desc = 'Snacks dim mode toggle',
    },
    {
      '<leader>nz',
      function()
        Snacks.zen()
      end,
      mode = 'n',
      desc = 'Snacks toggle zen mode',
    },
    {
      '<leader>nsc',
      function()
        Snacks.scratch()
      end,
      mode = 'n',
      desc = 'Snacks toggle scratch buffer',
    },
    {
      '<leader>nss',
      function()
        Snacks.scratch.select()
      end,
      mode = 'n',
      desc = 'Snacks select scratch buffer',
    },
    {
      '<leader>ni',
      function()
        Snacks.image.hover()
      end,
      mode = 'n',
      desc = 'Snacks show image',
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

        Snacks.toggle
          .option(
            'relativenumber',
            { name = 'Relative number', off = false, on = true }
          )
          :map '<leader>ntn'
        Snacks.toggle
          .option('scrollbind', { name = 'Scroll bind', off = false, on = true })
          :map '<leader>nts'
        Snacks.toggle.inlay_hints():map '<leader>nth'
      end,
    })
  end,
}
