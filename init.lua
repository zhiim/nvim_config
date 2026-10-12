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
-- |                     4. use firenvim                     |
-- +---------------------------------------------------------+
if vim.g.started_by_firenvim == true then
  vim.o.laststatus = 0
  vim.opt.cursorlone = false
  vim.cmd.colorscheme 'shine'

  vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('FirenvimInstall', { clear = true }),
    callback = function(ev)
      local data = ev.data

      if
        data.spec.name == 'firenvim'
        and (data.kind == 'install' or data.kind == 'update')
      then
        vim.cmd 'packadd firenvim'
        vim.fn['firenvim#install'](0)
      end
    end,
  })
  vim.pack.add {
    {
      src = 'https://github.com/glacambre/firenvim',
      name = 'firenvim',
    },
  }

  vim.g.firenvim_config = {
    localSettings = {
      ['.*'] = {
        takeover = 'never',
      },
    },
  }
  local pending = {}
  local interval = 200

  local function write_buffer(buf)
    if
      not vim.api.nvim_buf_is_valid(buf)
      or not vim.api.nvim_buf_is_loaded(buf)
      or not vim.bo[buf].modified
    then
      return
    end

    local ok, err = pcall(function()
      vim.api.nvim_buf_call(buf, function()
        vim.cmd 'silent write'
      end)
    end)

    if not ok then
      vim.notify(
        'Firenvim sync failed: ' .. tostring(err),
        vim.log.levels.ERROR
      )
    end
  end

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = vim.api.nvim_create_augroup('FirenvimAutoSync', {
      clear = true,
    }),

    callback = function(e)
      local buf = e.buf

      if pending[buf] then
        return
      end

      pending[buf] = true

      vim.defer_fn(function()
        pending[buf] = nil
        write_buffer(buf)
      end, interval)
    end,
  })
  vim.keymap.set('i', '<C-S-v>', '<C-r>+')

  return
end

-- +---------------------------------------------------------+
-- |                  5. Basic Autocommands                  |
-- +---------------------------------------------------------+
require 'config.autocmd'

-- +---------------------------------------------------------+
-- |          6. Install `lazy.nvim` plugin manager          |
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
-- |            7. Configure and install plugins             |
-- +---------------------------------------------------------+
--  To check the current status of your plugins, run
--    :Lazy
require 'plugins'
