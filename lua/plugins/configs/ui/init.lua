if vim.g.options.ui then
  return {
    require 'plugins.configs.ui.dashboard',
    require 'plugins.configs.ui.lualine',
    require 'plugins.configs.ui.incline',
    require 'plugins.configs.ui.theme',
    require 'plugins.configs.ui.enhance',
  }
else
  return {}
end
