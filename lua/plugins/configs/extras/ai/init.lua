if vim.g.options.ai then
  return {
    require 'plugins.configs.extras.ai.copilot',
    require 'plugins.configs.extras.ai.codecompanion',
  }
else
  return {}
end
