return {
  'f-person/git-blame.nvim',
  event = 'BufRead',
  config = function()
    vim.api.nvim_set_hl(0, 'GitBlame', {
      fg = require('utils.util').get_hl('Comment').fg,
      bg = require('utils.util').get_hl('CursorLine').bg,
    })
    require('gitblame').setup {
      enabled = true,
      message_template = ' <author> • <date> • <summary> • <<sha>>',
      date_format = '%Y-%m-%d',
      virtual_text_column = 1,
      highlight_group = 'GitBlame',
      ignored_filetypes = {},
      schedule_event = 'CursorMoved',
      clear_event = 'CursorMovedI',
    }
  end,
}
