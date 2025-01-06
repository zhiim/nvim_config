return {
  'f-person/git-blame.nvim',
  event = 'BufRead',
  config = function()
    local cur_line = require('utils.util').get_hl('CursorLine').bg
    vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
      pattern = { '*' },
      callback = function()
        local mode = vim.fn.mode()
        if mode == 'n' then -- normal mods
          vim.cmd('highlight GitBlame guibg=' .. cur_line)
        elseif mode == 'V' or mode == 'v' then -- visual mode
          vim.cmd 'highlight GitBlame guibg=NONE'
        end
      end,
    })
    require('gitblame').setup {
      enabled = true,
      message_template = ' 󰈻 <author> • <date> • <summary> • <<sha>>',
      message_when_not_committed = ' 󰈻 Not Committed Yet',
      date_format = '%Y-%m-%d',
      virtual_text_column = 1,
      highlight_group = 'GitBlame',
      ignored_filetypes = {},
      schedule_event = 'CursorMoved',
      clear_event = 'CursorMovedI',
    }
  end,
}
