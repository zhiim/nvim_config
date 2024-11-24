if vim.g.options.language_support then
  return {
    require 'plugins.configs.language.lspconfig',
    require 'plugins.configs.language.treesitter',
    require 'plugins.configs.language.cmp',
    require 'plugins.configs.language.conform',
    require 'plugins.configs.language.lint',
    require 'plugins.configs.language.tools',
    require 'plugins.configs.language.debug',
  }
else
  return {}
end
