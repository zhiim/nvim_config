if vim.g.options.git then
  return {
    require 'plugins.configs.git.mini_diff',
    require 'plugins.configs.git.diffview',
  }
else
  return {}
end
