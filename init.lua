vim.g.logo = [[
    ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
    ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
    ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
    ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
    ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
    ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
]]

-- +---------------------------------------------------------+
-- |             1. read user options from cache             |
-- +---------------------------------------------------------+
local cache_path = vim.fn.stdpath 'config' .. '/cache'

vim.g.options = {
  -- ━━ options to enable features ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  proxy = '',
  language_support = false,
  debug = false,
  git = false,
  ui = false,
  util = false,
  enhance = false,
  ai = false,
  tex = false,
  leetcode = false,
  tab = 'barbar', -- bufferline or barbar
  explorer = 'nvimtree', -- nvimtree or neotree
  -- ━━ Set colorscheme ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  color_scheme = 'github',
  scheme_style = 'github_dark_dimmed',
  -- ━━ use bash in windows ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  bash_path = '',
  -- ━━ gemini api key ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  gemini_api_key = '',
  -- ━━ command to find python env path ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -- in linux
  -- conda_command = "fd '^python$' /home/xu/miniconda3/envs -t x -t l"
  -- venv_command = "fd '^python$' /home/xu/.venvtool -t x -t l"
  python_conda_command = "fd '^python.exe$' D:\\condaEnvs -t x -t l",
  python_venv_command = "fd '^python.exe$' D:\\venv -t x -t l",
}

if vim.loop.fs_stat(cache_path) then
  -- if cache exists
  require('utils.util').read_options()
else
  -- if cache does not exist
  require('utils.util').write_options()
end

-- +---------------------------------------------------------+
-- |                     2. vim options                      |
-- +---------------------------------------------------------+
require 'config.options'

-- +---------------------------------------------------------+
-- |                     3. key mappings                     |
-- +---------------------------------------------------------+
require 'config.mappings'

-- +---------------------------------------------------------+
-- |                  4. Basic Autocommands                  |
-- +---------------------------------------------------------+
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

-- +---------------------------------------------------------+
-- |          5. Install `lazy.nvim` plugin manager          |
-- +---------------------------------------------------------+
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- +---------------------------------------------------------+
-- |            6. Configure and install plugins             |
-- +---------------------------------------------------------+
--  To check the current status of your plugins, run
--    :Lazy
require 'plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
