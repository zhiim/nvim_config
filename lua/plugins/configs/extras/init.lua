if vim.g.options.mode.chosen == 2 then
  return {
    require 'plugins.configs.extras.leetcode',
    require 'plugins.configs.extras.vimtex',
    require 'plugins.configs.extras.ai',
  }
else
  return {}
end
