return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
      theme = 'doom',
      config = {
        header = {
          '                                                       ',
          '                                                       ',
          '                                                       ',
          '                                                       ',
          '                                                       ',
          ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
          ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
          ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
          ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
          ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
          ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
          '                                                       ',
          '                                                       ',
          '                                                       ',
          '                                                       ',
          '                                                       ',
          '                                                       ',
        }, --your header
        center = {
          {
            icon = '  ',
            icon_hl = 'Title',
            desc = 'Read Saved Session',
            desc_hl = 'String',
            key = 's',
            keymap = 'SPC m s',
            key_hl = 'Number',
            key_format = ' %s',
            action = "lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Leader>msr', true, false, true), 'm', true)",
          },
          {
            icon = '󱋡  ',
            icon_hl = 'Title',
            desc = 'Find Recent Files',
            desc_hl = 'String',
            key = 'r',
            keymap = 'SPC s .',
            key_hl = 'Number',
            key_format = ' %s', -- remove default surrounding `[]`
            action = 'Telescope oldfiles',
          },
          {
            icon = '󰈞  ',
            icon_hl = 'Title',
            desc = 'Find File',
            desc_hl = 'String',
            key = 'f',
            keymap = 'SPC s f',
            key_hl = 'Number',
            key_format = ' %s',
            action = 'Telescope find_files',
          },
          {
            icon = '  ',
            icon_hl = 'Title',
            desc = 'Find Word',
            desc_hl = 'String',
            key = 'w',
            keymap = 'SPC s g',
            key_hl = 'Number',
            key_format = ' %s',
            action = 'Telescope live_grep',
          },
          {
            icon = '  ',
            icon_hl = 'Title',
            desc = 'New Files',
            desc_hl = 'String',
            key = 'e',
            key_hl = 'Number',
            key_format = ' %s',
            action = 'ene',
          },
        },
        footer = {}, --your footer
      },
    }
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
