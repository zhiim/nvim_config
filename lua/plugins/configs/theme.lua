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
      styles = {
        methods = 'italic',
        numbers = 'italic',
        strings = 'bold',
        comments = 'italic',
        keywords = 'bold,italic',
        constants = 'bold',
        functions = 'bold,undercurl',
        conditionals = 'italic',
      },
      filetypes = {
        all = true,
      },
    }
  end,
  ['onenord'] = function()
    set_theme()
    require('onenord').setup {
      styles = {
        comments = 'italic',
        strings = 'bold',
        keywords = 'underline',
        functions = 'bold,undercurl',
        diagnostics = 'underline',
      },
    }
  end,
  ['tokyonight'] = function()
    set_theme()
    require('tokyonight').setup {
      styles = {
        comments = { italic = true },
        keywords = { underline = true },
        functions = { bold = true, undercurl = true },
      },
    }
  end,
  ['nordic'] = function()
    set_theme()
    require('nordic').setup()
  end,
  ['catppuccin'] = function()
    set_theme()
    require('catppuccin').setup {
      styles = {
        comments = { 'italic' },
        conditionals = { 'italic' },
        functions = { 'bold', 'undercurl' },
        keywords = { 'underline' },
        strings = { 'bold' },
        numbers = { 'bold' },
        booleans = { 'bold' },
      },
    }
  end,
  ['material'] = function()
    vim.cmd.colorscheme 'material'
    vim.g.material_style = vim.g.scheme_style or 'deep ocean'
    require('material').setup {
      styles = {
        comments = { [[ italic = true ]] },
        strings = { [[ bold = true ]] },
        keywords = { [[ underline = true ]] },
        functions = { [[ bold = true, undercurl = true ]] },
        numbers = { [[ bold = true ]] },
        booleans = { [[ bold = true ]] },
      },
    }
  end,
  ['github'] = function()
    set_theme()
    require('github-theme').setup {
      styles = {
        comments = 'italic',
        functions = 'bold,undercurl',
        keywords = 'underline',
        strings = 'blod',
        numbers = 'bold',
        booleans = 'bold',
      },
    }
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
  priority = 1000, -- Ensure it loads first
  config = function()
    config_funcs[color_scheme]()
  end,
}
