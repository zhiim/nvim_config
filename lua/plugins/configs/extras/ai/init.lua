if vim.g.options.mode.chosen == 2 then
  return {
    require 'plugins.configs.extras.ai.copilot',
    require 'plugins.configs.extras.ai.codecompanion',
  }
else
  return {}
end
