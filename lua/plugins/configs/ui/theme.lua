local color_scheme = vim.g.options.color_scheme or 'onedark'
local theme_plugins = {
  ['onedark'] = 'olimorris/onedarkpro.nvim',
  ['onenord'] = 'rmehri01/onenord.nvim',
  ['tokyonight'] = 'folke/tokyonight.nvim',
  ['nordic'] = 'AlexvZyl/nordic.nvim',
  ['catppuccin'] = 'catppuccin/nvim',
  ['material'] = 'marko-cerovac/material.nvim',
  ['github'] = 'projekt0n/github-nvim-theme',
}

local function set_theme()
  vim.cmd.colorscheme(vim.g.options.scheme_style or color_scheme)
end

local config_funcs = {
  ['onedark'] = function()
    set_theme()
    require('onedarkpro').setup {
      filetypes = {
        all = true,
      },
    }
  end,
  ['onenord'] = function()
    vim.cmd.colorscheme 'onenord'
    require('onenord').setup {}
  end,
  ['tokyonight'] = function()
    set_theme()
    require('tokyonight').setup {}
  end,
  ['nordic'] = function()
    vim.cmd.colorscheme 'nordic'
    require('nordic').setup {}
  end,
  ['catppuccin'] = function()
    set_theme()
    require('catppuccin').setup {}
  end,
  ['material'] = function()
    vim.cmd.colorscheme 'material'
    vim.g.material_style = vim.g.scheme_style or 'deep ocean'
    require('material').setup {}
  end,
  ['github'] = function()
    set_theme()
    require('github-theme').setup {}
    -- set notify body to normal color
    vim.cmd [[
      highlight link NotifyERRORBody Normal
      highlight link NotifyWARNBody Normal
      highlight link NotifyINFOBody Normal
      highlight link NotifyDEBUGBody Normal
      highlight link NotifyTRACEBody Normal
    ]]
  end,
}

return {
  theme_plugins[color_scheme],
  priority = 1200, -- Ensure it loads first
  config = function()
    config_funcs[color_scheme]()
  end,
}
