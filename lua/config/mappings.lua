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
vim.api.nvim_set_keymap(
  'n',
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  'n',
  'k',
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, noremap = true, silent = true }
)

-- Diagnostic keymaps were predefined
vim.diagnostic.config { jump = { float = true } }

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Terminal Exit terminal mode' })

--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- remap Esc to jj and keep ESC, defined in better_escape.vim
-- map('i', 'jj', '<ESC>')
-- map('i', '<ESC>', '<ESC>')

-- mapping for split
map('n', '<leader>-', '<C-w>v', { desc = 'Split vertically' })
map('n', '<leader>=', '<C-w>s', { desc = 'Split horizontally' })
map('n', '<leader>o', '<cmd>only<CR>', { desc = 'close other windows' })

-- Comment
if vim.fn.has 'linux' ~= 0 and vim.fn.has 'wsl' == 0 then
  -- fix Ctrl + / in linux (wezterm, kitty)
  map('n', '<C-/>', 'gcc', { desc = 'comment toggle', remap = true })
  map('v', '<C-/>', 'gc', { desc = 'comment toggle', remap = true })
else
  map('n', '<C-_>', 'gcc', { desc = 'comment toggle', remap = true })
  map('v', '<C-_>', 'gc', { desc = 'comment toggle', remap = true })
end

-- cmd to change pyright type checking mode
vim.cmd "command! -nargs=1 PyrightTypeCheck lua require('utils.util').pyright_type_checking(<f-args>)"

-- mappings for ta
map('n', 'ga', '<cmd>tabnew<CR>', { desc = 'Tab new tab' })
map('n', 'gx', '<cmd>tabclose<CR>', { desc = 'Tab close tab' })
map('n', 'gt', '<cmd>tabn<CR>', { desc = 'Tab next tab' })
map('n', 'gT', '<cmd>tabp<CR>', { desc = 'Tab previous tab' })

-- cmake
map('n', '<leader>um', function()
  require('utils.util').gen_make_files()
end, { desc = 'utils generate cmake files' })

-- set options
map('n', '<leader>uoc', function()
  require('utils.option').set_options()
end, { desc = 'utils change user options' })

map('n', '<leader>uod', function()
  vim.print(vim.g.options)
end, { desc = 'utils display user options' })

-- mappings for cheatsheet
map('n', '<leader>uc', function()
  require('utils.cheatsheet').draw()
end, { desc = 'Utils display cheatsheet' })

map('n', '<leader>uf', function()
  require('utils.util').lint_format_config()
end, { desc = 'Utils create config file' })
