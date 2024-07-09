-- whether to use github copilot
vim.g.use_copilot = false

-- command to find python env path
-- in linux
-- conda_command = "fd '^python$' /home/xu/miniconda3/envs -t x -t l"
-- venv_command = "fd '^python$' /home/xu/.venvtool -t x -t l"
vim.g.python_conda_command = "fd '^python.exe$' D:\\condaEnvs -t x -t l"
vim.g.python_venv_command = "fd '^python.exe$' D:\\venv -t x -t l"

-- Set colorscheme
-- can be ['onedark', 'onenord', 'tokyonight', 'nordic', 'catppuccin']
vim.g.color_scheme = 'onedark'

-- [[ 1. vim options ]]
require 'config.options'

-- [[ 2. key mappings]]
require 'config.mappings'

-- [[ 3. Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ 4. Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ 5. Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
require 'plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
