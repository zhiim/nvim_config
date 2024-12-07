local color_scheme = vim.g.options.color_scheme or 'onedark'
local theme_plugins = {
  ['onedark'] = 'olimorris/onedarkpro.nvim',
  ['onenord'] = 'rmehri01/onenord.nvim',
  ['tokyonight'] = 'folke/tokyonight.nvim',
  ['nordic'] = 'AlexvZyl/nordic.nvim',
  ['catppuccin'] = 'catppuccin/nvim',
  ['material'] = 'marko-cerovac/material.nvim',
  ['github'] = 'projekt0n/github-nvim-theme',
  ['kanagawa'] = 'rebelot/kanagawa.nvim',
  ['nightfox'] = 'EdenEast/nightfox.nvim',
}

local function set_theme()
  vim.cmd.colorscheme(vim.g.options.scheme_style or color_scheme)
end

local config_funcs = {
  ['onedark'] = function()
    require('onedarkpro').setup {
      filetypes = {
        all = true,
      },
    }
    set_theme()
  end,
  ['onenord'] = function()
    require('onenord').setup {}
    vim.cmd.colorscheme 'onenord'
  end,
  ['tokyonight'] = function()
    require('tokyonight').setup {}
    set_theme()
  end,
  ['nordic'] = function()
    require('nordic').setup {}
    vim.cmd.colorscheme 'nordic'
  end,
  ['catppuccin'] = function()
    require('catppuccin').setup {}
    set_theme()
  end,
  ['material'] = function()
    require('material').setup {}
    vim.cmd.colorscheme 'material'
    vim.g.material_style = vim.g.scheme_style or 'deep ocean'
  end,
  ['github'] = function()
    require('github-theme').setup {}
    set_theme()
    -- set notify body to normal color
    vim.cmd [[
      highlight link NotifyERRORBody Normal
      highlight link NotifyWARNBody Normal
      highlight link NotifyINFOBody Normal
      highlight link NotifyDEBUGBody Normal
      highlight link NotifyTRACEBody Normal
    ]]
  end,
  ['kanagawa'] = function()
    require('kanagawa').setup {
      compile = true,
    }
    set_theme()
  end,
  ['nightfox'] = function()
    set_theme()
    require('nightfox').setup {}
  end,
}

return {
  theme_plugins[color_scheme],
  priority = 1200, -- Ensure it loads first
  config = function()
    config_funcs[color_scheme]()
  end,
}
