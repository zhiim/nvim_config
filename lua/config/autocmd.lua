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
    local colors = require('utils.palette').get_palette()

    local normal_bg = get_hl('Normal').bg
    local cursor_bg = get_hl('CursorLine').bg

    -- -- git symbols -----------------------------------------------------
    vim.api.nvim_set_hl(0, 'GitHunks', {
      fg = colors.purple,
    })

    -- -- custom selction highlight ---------------------------------------
    vim.api.nvim_set_hl(
      0,
      'MyPmenuSel',
      { bg = get_hl('Title').fg, fg = get_hl('Normal').bg }
    )

    -- -- float window ----------------------------------------------------
    -- highlight group for floating windows
    vim.api.nvim_set_hl(0, 'FloatBorder', {
      fg = get_hl('FloatBorder').fg,
      bg = get_hl('NormalFloat').bg,
    })
    vim.api.nvim_set_hl(0, 'NormalBorder', {
      fg = get_hl('FloatBorder').fg,
      bg = normal_bg,
    })

    -- -- Rainbow colors --------------------------------------------------
    vim.api.nvim_set_hl(0, 'ForeRed', { fg = colors.red })
    vim.api.nvim_set_hl(0, 'ForeYellow', { fg = colors.yellow })
    vim.api.nvim_set_hl(0, 'ForeBlue', { fg = colors.blue })
    vim.api.nvim_set_hl(0, 'ForeOrange', { fg = colors.orange })
    vim.api.nvim_set_hl(0, 'ForeGreen', { fg = colors.green })
    vim.api.nvim_set_hl(0, 'ForePurple', { fg = colors.purple })
    vim.api.nvim_set_hl(0, 'ForeCyan', { fg = colors.cyan })
    vim.api.nvim_set_hl(0, 'BackBlue', { fg = normal_bg, bg = colors.blue })
    vim.api.nvim_set_hl(0, 'BackRed', { fg = normal_bg, bg = colors.red })
    vim.api.nvim_set_hl(0, 'BackGreen', { fg = normal_bg, bg = colors.green })
    vim.api.nvim_set_hl(0, 'BackYellow', { fg = normal_bg, bg = colors.yellow })
    vim.api.nvim_set_hl(0, 'backOrange', { fg = normal_bg, bg = colors.orange })
    vim.api.nvim_set_hl(0, 'BackPurple', { fg = normal_bg, bg = colors.purple })
    vim.api.nvim_set_hl(0, 'BackCyan', { fg = normal_bg, bg = colors.cyan })

    -- -- cheatsheet ------------------------------------------------------
    vim.api.nvim_set_hl(0, 'ChAsciiHeader', { fg = get_hl('Title').fg })
    vim.api.nvim_set_hl(
      0,
      'ChSection',
      { fg = get_hl('Normal').fg, bg = get_hl('ColorColumn').bg }
    )

    -- -- neo-tree --------------------------------------------------------
    vim.api.nvim_set_hl(0, 'NeoTreeModified', { fg = colors.red })

    -- -- git blame -------------------------------------------------------
    vim.api.nvim_set_hl(0, 'GitBlame', {
      fg = get_hl('Comment').fg,
      bg = cursor_bg,
    })

    -- -- hl-groups for symbol usage --------------------------------------
    vim.api.nvim_set_hl(
      0,
      'SymbolUsageRounding',
      { fg = cursor_bg, italic = true }
    )
    vim.api.nvim_set_hl(
      0,
      'SymbolUsageContent',
      { bg = cursor_bg, fg = get_hl('Comment').fg, italic = true }
    )
    vim.api.nvim_set_hl(0, 'SymbolUsageRef', {
      fg = get_hl('Function').fg,
      bg = cursor_bg,
      italic = true,
    })
    vim.api.nvim_set_hl(
      0,
      'SymbolUsageDef',
      { fg = get_hl('Type').fg, bg = cursor_bg, italic = true }
    )
    vim.api.nvim_set_hl(0, 'SymbolUsageImpl', {
      fg = get_hl('@keyword').fg,
      bg = cursor_bg,
      italic = true,
    })

    -- -- highlight undo --------------------------------------------------
    vim.api.nvim_set_hl(0, 'HighlightUndo', { link = 'Visual' })

    -- -- highlight group for telescope -----------------------------------
    local bg = get_hl('NormalFloat').bg
    local preview_title = colors.green
    local prompt_title_bg = colors.blue
    local result_title_bg = colors.orange
    -- return a table of highlights for telescope based on
    -- colors gotten from highlight groups
    vim.api.nvim_set_hl(0, 'TelescopeBorder', { link = 'FloatBorder' })
    vim.api.nvim_set_hl(0, 'TelescopeNormal', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(0, 'TelescopePreviewBorder', { link = 'FloatBorder' })
    vim.api.nvim_set_hl(0, 'TelescopePreviewNormal', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(
      0,
      'TelescopePreviewTitle',
      { fg = bg, bg = preview_title }
    )
    vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { link = 'FloatBorder' })
    vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(
      0,
      'TelescopePromptPrefix',
      { fg = prompt_title_bg, bg = bg }
    )
    vim.api.nvim_set_hl(
      0,
      'TelescopePromptTitle',
      { fg = bg, bg = prompt_title_bg }
    )
    vim.api.nvim_set_hl(0, 'TelescopeResultsBorder', { link = 'FloatBorder' })
    vim.api.nvim_set_hl(0, 'TelescopeResultsNormal', { link = 'NormalFloat' })
    vim.api.nvim_set_hl(
      0,
      'TelescopeResultsTitle',
      { fg = bg, bg = result_title_bg }
    )

    -- -- noice -----------------------------------------------------------
    vim.api.nvim_set_hl(
      0,
      'MyMiniBorder',
      { bg = normal_bg, fg = get_hl('FloatBorder').fg }
    )
  end,
})
