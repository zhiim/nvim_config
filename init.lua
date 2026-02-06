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
local opts_default_path = vim.fn.stdpath 'config' .. '/opts_default.json'
local opts_cache_path = vim.fn.stdpath 'config' .. '/opts_cache.json'

vim.g.options = {}

if (vim.uv or vim.loop).fs_stat(opts_cache_path) then
  -- if cache exists
  require('utils.util').read_options(opts_cache_path)
else
  -- if cache does not exist
  require('utils.util').read_options(opts_default_path)
  require('utils.util').write_options(opts_cache_path)
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
