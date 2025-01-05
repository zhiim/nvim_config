local M = {}

--- get palette according to color_scheme
function M.get_palette()
  -- default_palette using habamax colorscheme
  local default_palette = {
    red = '#d75f5f',
    yellow = '#afaf87',
    blue = '#5f87af',
    orange = '#d7875f',
    green = '#87af87',
    purple = '#af87af',
    cyan = '#5f8787',
  }
  if not vim.g.options.ui then
    return default_palette
  end
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
      local palette = require('github-theme.palette').load(
        vim.g.options.theme_style ~= '' and vim.g.options.theme_style
          or 'github_dark'
      )
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
    kanagawa = function()
      local colors = require('kanagawa.colors').setup()
      local theme_colors = colors.theme.term
      return {
        red = theme_colors[2],
        yellow = theme_colors[4],
        blue = theme_colors[5],
        orange = theme_colors[17],
        green = theme_colors[3],
        purple = theme_colors[6],
        cyan = theme_colors[7],
      }
    end,
    nightfox = function()
      local palette = require('nightfox.palette').load(
        vim.g.options.theme_style ~= '' and vim.g.options.theme_style
          or 'nightfox'
      )
      return {
        red = palette.red.base,
        yellow = palette.yellow.base,
        blue = palette.blue.base,
        orange = palette.orange.base,
        green = palette.green.base,
        purple = palette.magenta.base,
        cyan = palette.cyan.base,
      }
    end,
    everforest = function()
      local palette = require('everforest.colours').generate_palette(
        require('everforest').config,
        vim.o.background
      )
      return {
        red = palette.red,
        yellow = palette.yellow,
        blue = palette.blue,
        orange = palette.orange,
        green = palette.green,
        purple = palette.purple,
        cyan = palette.aqua,
      }
    end,
    gruvbox = function()
      local palette = require('gruvbox').palette
      return {
        red = palette.neutral_red,
        yellow = palette.neutral_yellow,
        blue = palette.neutral_blue,
        orange = palette.neutral_orange,
        green = palette.neutral_green,
        purple = palette.neutral_purple,
        cyan = palette.faded_aqua,
      }
    end,
  }
  local color_scheme = vim.g.options.theme == '' and 'github'
    or vim.g.options.theme
  return palette_funcs[color_scheme]()
end

return M
