if vim.g.options.git then
  return {
    require 'plugins.configs.git.gitsigns',
    require 'plugins.configs.git.diffview',
  }
else
  return {}
end
