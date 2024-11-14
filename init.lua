--  +-------------------------------------------------------------------------+
--  |                     1. read user options from cache                     |
--  +-------------------------------------------------------------------------+
local cache_path = vim.fn.stdpath 'config' .. '/cache'

vim.g.options = {
  -- ━━ options to enable features ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  proxy = '',
  enable_language_support = false,
  use_copilot = false,
  use_dap = false,
  use_tex = false,
  enable_leetcode = false,
  enable_enhance = false,
  tab_tool = 'barbar', -- bufferline or barbar
  file_explorer = 'nvimtree', -- nvimtree or neotree
  -- ━━ command to find python env path ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  -- in linux
  -- conda_command = "fd '^python$' /home/xu/miniconda3/envs -t x -t l"
  -- venv_command = "fd '^python$' /home/xu/.venvtool -t x -t l"
  python_conda_command = "fd '^python.exe$' D:\\condaEnvs -t x -t l",
  python_venv_command = "fd '^python.exe$' D:\\venv -t x -t l",
  -- ━━ Set colorscheme ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  --   'onedark':
  --      ['onedark', 'onelight', 'onedark_vivid', 'onedark_dark']
  --   'tokyonight':
  --      ['tokyonight-night', 'tokyonight-storm', 'tokyonight-day',
  --       'tokyonight-moon']
  --   'catppuccin':
  --      ['catppuccin-latte', 'catppuccin-frappe',
  --       'catppuccin-macchiato', 'catppuccin-mocha']
  --   'material':
  --      ['darker', 'lighter', 'oceanic', 'palenight', 'deep ocean']
  --   'github':
  --      ['github_dark', 'github_light', 'github_dark_dimmed',
  --       'github_dark_default', 'github_light_default',
  --       'github_dark_high_contrast', 'github_light_high_contrast',
  --       'github_dark_colorblind', 'github_light_colorblind',
  --       'github_dark_tritanopia', 'github_light_tritanopia']
  --   'onenord'
  --   'nordic'
  color_scheme = 'github',
  scheme_style = 'github_dark_dimmed',
  -- ━━ use git bash in windows ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  git_bash_path = '',
}

if vim.loop.fs_stat(cache_path) then
  -- if cache exists
  require('utils.util').with_file(cache_path, 'r', function(file)
    -- read cache into options
    vim.g.options = require('utils.json').decode(file:read '*a')
  end, function(err)
    vim.notify('Error reading cache file: ' .. err, vim.log.levels.ERROR, { title = 'Cache Read' })
  end)
else
  -- if cache does not exist
  require('utils.util').with_file(cache_path, 'w+', function(file)
    -- write default options into cache
    file:write(require('utils.json').encode(vim.g.options))
  end, function(err)
    vim.notify('Error writing cache file: ' .. err, vim.log.levels.ERROR, { title = 'Cache Write' })
  end)
end

--  +-------------------------------------------------------------------------+
--  |                             2. vim options                              |
--  +-------------------------------------------------------------------------+
require 'config.options'

--  +-------------------------------------------------------------------------+
--  |                             3. key mappings                             |
--  +-------------------------------------------------------------------------+
require 'config.mappings'

--  +-------------------------------------------------------------------------+
--  |                          4. Basic Autocommands                          |
--  +-------------------------------------------------------------------------+
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

--  +-------------------------------------------------------------------------+
--  |                  5. Install `lazy.nvim` plugin manager                  |
--  +-------------------------------------------------------------------------+
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

--  +-------------------------------------------------------------------------+
--  |                    6. Configure and install plugins                     |
--  +-------------------------------------------------------------------------+
--  To check the current status of your plugins, run
--    :Lazy
require 'plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
