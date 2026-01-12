if vim.g.options.mode == 'IDE' then
  return {
    require 'plugins.configs.git.mini_diff',
    require 'plugins.configs.git.blame',
    require 'plugins.configs.git.codediff',
  }
else
  return {}
end
