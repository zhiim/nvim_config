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

-- Diagnostic keymaps were predefined
vim.diagnostic.config { jump = { float = true } }

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

-- cmake
map('n', '<leader>mk', function()
  require('utils.util').gen_make_files()
end, { desc = 'cmake build' })

-- set options
map('n', '<leader>nf', function()
  require('utils.util').set_options()
end, { desc = 'Neovim user config' })

map('n', '<leader>nd', function()
  vim.print(vim.g.options)
end, { desc = 'Display user config' })

-- cmd to change pyright type checking mode
vim.cmd "command! -nargs=1 PyrightTypeCheck lua require('utils.util').pyright_type_checking(<f-args>)"

-- mappings for ta
map('n', 'ga', '<cmd>$tabnew<CR>', { desc = 'tab new' })
map('n', 'gx', '<cmd>tabclose<CR>', { desc = 'tab close' })
