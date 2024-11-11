-- [[ Basic Keymaps ]]
-- plugins lazy loaded with cmd should be mapped here
--  See `:help map()`
local map = vim.keymap.set

-- clear on pressing <Esc> in normal mode
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- move in insert mode
map('i', '<C-j>', '<Down>', { noremap = true })
map('i', '<C-k>', '<Up>', { noremap = true })
map('i', '<C-h>', '<Left>', { noremap = true })
map('i', '<C-l>', '<Right>', { noremap = true })

-- move inside the same line when this line exceeds the window width
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, noremap = true, silent = true })

-- Diagnostic keymaps
map('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next [D]iagnostic message' })
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

-- Comment
map('n', '<C-_>', 'gcc', { desc = 'comment toggle', remap = true })
map('v', '<C-_>', 'gc', { desc = 'comment toggle', remap = true })

-- for diffview
map('n', '<leader>dv', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview Open' })
map('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview Close' })
map('n', '<leader>dh', '<cmd>DiffviewFileHistory<cr>', { desc = 'Diffview View Files History' })

-- cmake
map('n', '<leader>mk', function()
  require('utils.util').gen_make_files()
end, { desc = 'cmake build' })

-- toggleterm
map({ 'n', 't' }, '<A-u>', '<cmd>ToggleTerm direction=horizontal<CR>', { desc = 'Toggle terminal in horizontal' })
map({ 'n', 't' }, '<A-i>', '<cmd>ToggleTerm direction=float<CR>', { desc = 'Toggle terminal in float' })
map({ 'n', 't' }, '<A-o>', '<cmd>ToggleTerm direction=vertical<CR>', { desc = 'Toggle terminal in vertical' })

--smart-split
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

if vim.g.enable_language_support then
  -- treesitter-context
  map('n', '<leader>tct', '<cmd>TSContextToggle<CR>', { desc = 'Toggle Treesitter Context' })

  -- glance
  map('n', '<leader>gd', '<CMD>Glance definitions<CR>', { desc = 'Glance definitions' })
  map('n', '<leader>gr', '<CMD>Glance references<CR>', { desc = 'Glance references' })
  map('n', '<leader>gD', '<CMD>Glance type_definitions<CR>', { desc = 'Glance type definitions' })
  map('n', '<leader>gI', '<CMD>Glance implementations<CR>', { desc = 'Glance implementations' })
end
