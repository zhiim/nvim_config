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
      styles = {
        types = 'NONE',
        methods = 'NONE',
        numbers = 'NONE',
        strings = 'NONE',
        comments = 'italic',
        keywords = 'bold,italic',
        constants = 'bold',
        functions = 'italic',
        operators = 'NONE',
        variables = 'NONE',
        parameters = 'NONE',
        conditionals = 'italic',
        virtual_text = 'NONE',
      },
    }
    set_theme()
  end,
  ['onenord'] = function()
    require('onenord').setup {
      styles = {
        comments = 'italic',
        strings = 'NONE',
        keywords = 'bold,italic',
        functions = 'italic',
        variables = 'NONE',
        diagnostics = 'underline',
      },
    }
    vim.cmd.colorscheme 'onenord'
  end,
  ['tokyonight'] = function()
    ---@diagnostic disable-next-line: missing-fields
    require('tokyonight').setup {
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = true },
        keywords = { bold = true, italic = true },
        functions = { italic = true },
        variables = {},
      },
    }
    set_theme()
  end,
  ['nordic'] = function()
    require('nordic').setup {
      bold_keywords = true,
      -- Enable italic comments.
      italic_comments = true,
      telescope = {
        -- Available styles: `classic`, `flat`.
        style = 'classic',
      },
    }
    vim.cmd.colorscheme 'nordic'
  end,
  ['catppuccin'] = function()
    require('catppuccin').setup {
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { 'italic' }, -- Change the style of comments
        conditionals = { 'italic' },
        loops = {},
        functions = { 'italic' },
        keywords = { 'bold', 'italic' },
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      integrations = {
        barbar = true,
        diffview = true,
        dropbar = {
          enabled = true,
          color_mode = true, -- enable color for kind's texts, not just kind's icons
        },
        grug_far = true,
        mason = true,
        noice = true,
        snacks = true,
        lsp_trouble = true,
        which_key = true,
      },
    }
    set_theme()
  end,
  ['material'] = function()
    require('material').setup {
      styles = {
        comments = { italic = true },
        strings = {},
        keywords = { bold = true, italic = true },
        functions = { italic = true },
        variables = {},
        operators = {},
        types = {},
      },
      plugins = {
        'dap',
        'dashboard',
        'flash',
        'indent-blankline',
        'mini',
        'neo-tree',
        'noice',
        'nvim-cmp',
        'nvim-tree',
        'telescope',
        'trouble',
        'which-key',
      },
      lualine_style = 'stealth', -- Lualine style ( can be 'stealth' or 'default' )
    }
    vim.g.material_style = vim.g.options.theme_style ~= ''
        and vim.g.options.theme_style
      or 'deep ocean'
    vim.cmd.colorscheme 'material'
  end,
  ['github'] = function()
    require('github-theme').setup {
      options = {
        styles = { -- Style to be applied to different syntax groups
          comments = 'italic', -- Value is any valid attr-list value `:help attr-list`
          functions = 'italic',
          keywords = 'bold,italic',
          variables = 'NONE',
          conditionals = 'italic',
          constants = 'bold',
          numbers = 'NONE',
          operators = 'NONE',
          strings = 'NONE',
          types = 'NONE',
        },
      },
    }
    vim.cmd.colorscheme(
      vim.g.options.theme_style ~= '' and vim.g.options.theme_style
        or 'github_dark'
    )
  end,
  ['kanagawa'] = function()
    require('kanagawa').setup {
      compile = false,
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = { italic = true },
      keywordStyle = { bold = true, italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      colors = { -- add/modify theme and palette colors
        theme = {
          all = {
            ui = {
              bg_gutter = 'none',
            },
          },
        },
      },
    }
    set_theme()
  end,
  ['nightfox'] = function()
    require('nightfox').setup {
      options = {
        styles = { -- Style to be applied to different syntax groups
          comments = 'italic', -- Value is any valid attr-list value `:help attr-list`
          conditionals = 'italic',
          constants = 'bold',
          functions = 'italic',
          keywords = 'bold,italic',
          numbers = 'NONE',
          operators = 'NONE',
          strings = 'NONE',
          types = 'NONE',
          variables = 'NONE',
        },
      },
    }
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
