local M = {}

function M.get_palette()
  local palette_funcs = {
    onedark = function()
      return require('onedarkpro.helpers').get_colors()
    end,
    onenord = function()
      return require('onenord.colors').load()
    end,
    tokyonight = function()
      return require('tokyonight.colors').setup()
    end,
    nordic = function()
      local palette = require 'nordic.colors'
      return {
        red = palette.red.base,
        yellow = palette.yellow.base,
        blue = palette.blue0,
        orange = palette.orange.base,
        green = palette.green.base,
        purple = palette.magenta.base,
        cyan = palette.cyan.base,
      }
    end,
    catppuccin = function()
      local palette = require('catppuccin.palettes').get_palette()
      return {
        red = palette.red,
        yellow = palette.yellow,
        blue = palette.blue,
        orange = palette.flamingo,
        green = palette.green,
        purple = palette.mauve,
        cyan = palette.teal,
      }
    end,
    material = function()
      return require('material.colors').main
    end,
    github = function()
      local palette = require('github-theme.palette').load(vim.g.scheme_style)
      return {
        red = palette.red.base,
        yellow = palette.yellow.base,
        blue = palette.blue.base,
        orange = palette.orange,
        green = palette.green.base,
        purple = palette.magenta.base,
        cyan = palette.cyan.base,
      }
    end,
  }
  local color_scheme = vim.g.color_scheme or 'onedark'
  return palette_funcs[color_scheme]()
end

return M
