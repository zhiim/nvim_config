return {
  'f-person/git-blame.nvim',
  event = 'BufRead',
  config = function()
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
