if vim.g.options.ai then
  return {
    require 'plugins.configs.extras.ai.copilot',
    require 'plugins.configs.extras.ai.codecompanion',
    require 'plugins.configs.extras.ai.gemini_cli',
  }
else
  return {}
end
