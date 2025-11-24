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
vim.g.cache_path = vim.fn.stdpath 'config' .. '/cache.json'

vim.g.options = {
  -- ━━ options to enable features ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ai = false,
  tex = false,
  leetcode = false,
  mode = 'minimal',
  proxy = '',
  picker = 'fzf_lua',
  cmp = 'blink_cmp',
  tab = 'barbar',
  explorer = 'neotree',
  -- ━━ Set colorscheme ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  theme = 'github',
  theme_style = 'github_dark_dimmed',
  -- ━━ use bash in windows ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  bash_path = '',
  -- ━━ api key ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  xai_api_key = '',
  gemini_api_key = '',
  -- ━━ command to find python env path ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -- in linux
  -- conda_command = "fd '^python$' /home/xu/miniconda3/envs -t x -t l"
  -- venv_command = "fd '^python$' /home/xu/.venvtool -t x -t l"
  python_conda_command = "fd '^python.exe$' D:\\condaEnvs -t x -t l",
  python_venv_command = "fd '^python.exe$' D:\\venv -t x -t l",
}

if (vim.uv or vim.loop).fs_stat(vim.g.cache_path) then
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
require 'config.autocmd'

-- +---------------------------------------------------------+
-- |          5. Install `lazy.nvim` plugin manager          |
-- +---------------------------------------------------------+
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- +---------------------------------------------------------+
-- |            6. Configure and install plugins             |
-- +---------------------------------------------------------+
--  To check the current status of your plugins, run
--    :Lazy
require 'plugins'
