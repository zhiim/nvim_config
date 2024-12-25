local color_scheme = vim.g.options.theme ~= '' and vim.g.options.theme
  or 'github'
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
  ['everforest'] = 'neanias/everforest-nvim',
}

local function set_theme()
  vim.cmd.colorscheme(
    vim.g.options.theme_style ~= '' and vim.g.options.theme_style
      or color_scheme
  )
end

local config_funcs = {
  ['onedark'] = function()
    require('onedarkpro').setup {
      filetypes = {
        all = true,
      },
      options = {
        cursorline = true,
        transparency = false, -- Use a transparent background?
        terminal_colors = true, -- Use the theme's colors for Neovim's :terminal?
        lualine_transparency = false, -- Center bar transparency?
        highlight_inactive_windows = false, -- When the window is out of focus, change the normal background?
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
    vim.g.material_style = vim.g.options.theme_style ~= ''
        and vim.g.options.theme_style
      or 'deep ocean'
  end,
  ['github'] = function()
    require('github-theme').setup {}
    vim.cmd.colorscheme(
      vim.g.options.theme_style ~= '' and vim.g.options.theme_style
        or 'github_dark'
    )
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
    require('nightfox').setup {}
    set_theme()
  end,
  ['everforest'] = function()
    require('everforest').setup {}
    vim.cmd.colorscheme 'everforest'
  end,
}

return {
  theme_plugins[color_scheme],
  priority = 1200, -- Ensure it loads first
  config = function()
    config_funcs[color_scheme]()
  end,
}
