if vim.g.options.util then
  return {
    require 'plugins.configs.util.mini',
    require 'plugins.configs.util.snacks',
  }
else
  return {}
end
