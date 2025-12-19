if vim.g.options.mode == 'IDE' then
  return {
    require 'plugins.configs.git.mini_diff',
    require 'plugins.configs.git.diffview',
    require 'plugins.configs.git.blame',
    require 'plugins.configs.git.vscode_diff',
  }
else
  return {}
end
