local function augroup(name)
  return vim.api.nvim_create_augroup('nvim_' .. name, { clear = true })
end

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup 'highlight-yank',
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup 'checktime',
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd 'checktime'
    end
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = augroup 'resize_splits',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup 'last_loc',
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if
      vim.tbl_contains(exclude, vim.bo[buf].filetype)
      or vim.b[buf].lazyvim_last_loc
    then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = augroup 'auto_create_dir',
  callback = function(event)
    if event.match:match '^%w%w+:[\\/][\\/]' then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'close_with_q',
  pattern = {
    'checkhealth',
    'help',
    'qf',
    'lspinfo',
    'notify',
    'snacks_win',
    'dap-float',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

-- set highlight group after load theme
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    -- set highlight group after load theme
    local get_hl = require('utils.util').get_hl
    local colors = require('utils.util').get_palette()

    -- highlight group for floating windows
    vim.api.nvim_set_hl(
      0,
      'PmenuSel',
      { bg = get_hl('Title').fg, fg = get_hl('Normal').bg }
    )
    vim.api.nvim_set_hl(0, 'FloatBorder', {
      fg = get_hl('FloatBorder').fg,
      bg = get_hl('NormalFloat').bg,
      bold = true,
    })

    vim.api.nvim_set_hl(0, 'RainbowRed', { fg = colors.red })
    vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = colors.yellow })
    vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = colors.blue })
    vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = colors.orange })
    vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = colors.green })
    vim.api.nvim_set_hl(
      0,
      'RainbowViolet',
      { fg = colors.purple and colors.purple or colors.magenta }
    )
    vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = colors.cyan })

    -- highlight group for cheatsheet
    vim.api.nvim_set_hl(0, 'ChAsciiHeader', { fg = get_hl('Title').fg })
    vim.api.nvim_set_hl(
      0,
      'ChSection',
      { fg = get_hl('Normal').fg, bg = get_hl('ColorColumn').bg }
    )
    vim.api.nvim_set_hl(
      0,
      'ChBlue',
      { fg = get_hl('Normal').bg, bg = colors.blue }
    )
    vim.api.nvim_set_hl(
      0,
      'ChRed',
      { fg = get_hl('Normal').bg, bg = colors.red }
    )
    vim.api.nvim_set_hl(
      0,
      'ChGreen',
      { fg = get_hl('Normal').bg, bg = colors.green }
    )
    vim.api.nvim_set_hl(
      0,
      'ChYellow',
      { fg = get_hl('Normal').bg, bg = colors.yellow }
    )
    vim.api.nvim_set_hl(
      0,
      'ChOrange',
      { fg = get_hl('Normal').bg, bg = colors.orange }
    )
    vim.api.nvim_set_hl(
      0,
      'ChMagenta',
      { fg = get_hl('Normal').bg, bg = colors.purple }
    )
    vim.api.nvim_set_hl(
      0,
      'ChCyan',
      { fg = get_hl('Normal').bg, bg = colors.cyan }
    )

    vim.api.nvim_set_hl(0, 'NeoTreeModified', { fg = colors.red })
  end,
})
