-- [[ Basic Keymaps ]]
--  See `:help map()`
local map = vim.keymap.set

-- clear on pressing <Esc> in normal mode
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
map('t', '<A-n>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- remap Esc to jj and keep ESC
map('i', 'jj', '<ESC>')
map('i', '<ESC>', '<ESC>')

-- mapping for split
map('n', '<leader>-', '<C-w>v', { desc = 'split vertically' })
map('n', '<leader>=', '<C-w>s', { desc = 'split horizontally' })
map('n', '<leader>o', '<cmd>only<CR>', { desc = 'close other windows' })

-- nvimtree
map('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')

-- Comment
map('n', '<C-_>', 'gcc', { desc = 'comment toggle', remap = true })
map('v', '<C-_>', 'gc', { desc = 'comment toggle', remap = true })

-- barbar
map('n', '<tab>', '<cmd>BufferNext<CR>', { desc = 'buffer goto next' })
map('n', '<S-tab>', '<cmd>BufferPrevious<CR>', { desc = 'buffer goto previous' })
map('n', '<leader>x', '<cmd>BufferClose<CR>', { desc = 'buffer close', noremap = true, silent = true })

-- smart-split
map('n', '<C-h>', function()
  require('smart-splits').move_cursor_left()
end, { desc = 'Move Left' })
map('n', '<C-l>', function()
  require('smart-splits').move_cursor_right()
end, { desc = 'Move Right' })
map('n', '<C-j>', function()
  require('smart-splits').move_cursor_down()
end, { desc = 'Move Down' })
map('n', '<C-k>', function()
  require('smart-splits').move_cursor_up()
end, { desc = 'Move Up' })
map('n', '<A-h>', function()
  require('smart-splits').resize_left()
end, { desc = 'Resize Left' })
map('n', '<A-l>', function()
  require('smart-splits').resize_right()
end, { desc = 'Resize Right' })
map('n', '<A-j>', function()
  require('smart-splits').resize_down()
end, { desc = 'Resize Down' })
map('n', '<A-k>', function()
  require('smart-splits').resize_up()
end, { desc = 'Resize Up' })

-- trouble.nvim
map('n', '<leader>tw', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Trouble Toggle Workspace Diagnostics' })
map('n', '<leader>tt', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Trouble Toggle Buffer Diagnostics' })
map('n', '<leader>tl', '<cmd>Trouble loclist toggle<cr>', { desc = 'Trouble Toggle Loclist' })
map('n', '<leader>tq', '<cmd>Trouble qflist toggle<cr>', { desc = 'Trouble Toggle Quickfix' })
map('n', '<leader>lr', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'Trouble Toggle LSP References' })

-- lazygit
map('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'Open LazyGit' })

-- glow.nvim
map('n', '<leader>gl', '<cmd>Glow<cr>', { desc = 'Glow Open preview windows' })

-- for diffview
map('n', '<leader>dv', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview Open' })
map('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview Close' })
map('n', '<leader>dh', '<cmd>DiffviewFileHistory<cr>', { desc = 'Diffview View Files History' })

-- cmake
map('n', '<leader>mk', function()
  if vim.fn.executable 'cmake' == 0 then
    print 'cmake not found'
    return
  end
  -- create build dir
  if vim.fn.isdirectory 'build' == 0 then
    vim.fn.mkdir 'build'
  end
  -- generate build files
  local gen_result
  if vim.fn.has 'win32' == 1 then
    gen_result = vim.fn.system 'cmake -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -S . -B build -G "MinGW Makefiles"'
  else
    gen_result = vim.fn.system 'cmake -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -S . -B build'
  end
  print(vim.inspect(gen_result))
end, { desc = 'cmake build' })

-- copilot
map('i', '<A-y>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
  desc = 'Accept copilot suggestion',
})
vim.g.copilot_no_tab_map = true
map('n', '<leader>co', '<cmd>CopilotChatOpen<CR>', { desc = 'Open Copilot Chat' })
map('n', '<leader>cc', '<cmd>CopilotChatClose<CR>', { desc = 'Close Copilot Chat' })
map('n', '<leader>ct', '<cmd>CopilotChatToggle<CR>', { desc = 'Toggle Copilot Chat' })

-- toggleterm
map({ 'n', 't' }, '<A-i>', '<cmd>ToggleTerm direction=float<CR>', { desc = 'Toggle terminal in float' })
map({ 'n', 't' }, '<A-v>', '<cmd>ToggleTerm direction=horizontal size=15<CR>', { desc = 'Toggle terminal in horizontal' })

-- treesitter-context
map('n', '<leader>tct', '<cmd>TSContextToggle<CR>', { desc = 'Toggle Treesitter Context' })

-- glance
map('n', '<leader>gd', '<CMD>Glance definitions<CR>', { desc = 'Glance definitions' })
map('n', '<leader>gr', '<CMD>Glance references<CR>', { desc = 'Glance references' })
map('n', '<leader>gD', '<CMD>Glance type_definitions<CR>', { desc = 'Glance type definitions' })
map('n', '<leader>gI', '<CMD>Glance implementations<CR>', { desc = 'Glance implementations' })
