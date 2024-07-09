local util = {}

function util.get_palette(color_scheme)
  if color_scheme == 'onenord' then
    return require('onenord.colors').load()
  elseif color_scheme == 'tokyonight' then
    return require('tokyonight.colors').setup()
  elseif color_scheme == 'nordic' then
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
  elseif color_scheme == 'catppuccin' then
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
  else
    return require('onedarkpro.helpers').get_colors()
  end
end

return util
