local color_scheme = vim.g.color_scheme or 'onedark'
local theme_plugins = {
  ['onedark'] = 'olimorris/onedarkpro.nvim',
  ['onenord'] = 'rmehri01/onenord.nvim',
  ['tokyonight'] = 'folke/tokyonight.nvim',
  ['nordic'] = 'AlexvZyl/nordic.nvim',
  ['catppuccin'] = 'catppuccin/nvim',
  ['material'] = 'marko-cerovac/material.nvim',
}
return {
  theme_plugins[color_scheme],
  priority = 1000, -- Ensure it loads first
  config = function()
    local theme_style = vim.g.scheme_style or color_scheme
    vim.cmd.colorscheme(theme_style)
    if color_scheme == 'catppuccin' then
      require('catppuccin').setup {
        integrations = {
          barbar = true,
          diffview = true,
          mason = true,
          nvimtree = true,
          lsp_trouble = true,
          which_key = true,
        },
      }
    end
  end,
}
