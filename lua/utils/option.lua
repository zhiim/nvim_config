local utils = require 'utils.util'
local M = {}

-- set user options and write to cache
function M.set_options()
  local style_options = {
    onedark = { 'onedark', 'onelight', 'onedark_vivid', 'onedark_dark' },
    tokyonight = {
      'tokyonight-night',
      'tokyonight-storm',
      'tokyonight-day',
      'tokyonight-moon',
    },
    catppuccin = {
      'catppuccin-latte',
      'catppuccin-frappe',
      'catppuccin-macchiato',
      'catppuccin-mocha',
    },
    material = { 'darker', 'lighter', 'oceanic', 'palenight', 'deep ocean' },
    github = {
      'github_dark',
      'github_light',
      'github_dark_dimmed',
      'github_dark_default',
      'github_light_default',
      'github_dark_high_contrast',
      'github_light_high_contrast',
      'github_dark_colorblind',
      'github_light_colorblind',
      'github_dark_tritanopia',
      'github_light_tritanopia',
    },
    kanagawa = { 'kanagawa-wave', 'kanagawa-dragon', 'kanagawa-lotus' },
    nightfox = {
      'carbonfox',
      'dawnfox',
      'dayfox',
      'duskfox',
      'nightfox',
      'nordfox',
      'terafox',
    },
  }
  local selections = {
    cmp = { 'nvim_cmp', 'blink_cmp' },
    tab = { 'barbar', 'bufferline', 'tabby' },
    explorer = { 'nvimtree', 'neotree' },
    theme = {
      'github',
      'tokyonight',
      'catppuccin',
      'nightfox',
      'kanagawa',
      'onedark',
      'everforest',
      'onenord',
      'nordic',
      'gruvbox',
      'material',
    },
    -- theme_style options
    theme_style = style_options[vim.g.options.theme] or {},
  }
  local option_info = {
    proxy = 'Proxy settings',
    language_support = 'Enable LSP, Treesitter, Linter, Formatter and other tools based on them',
    debug = 'Enable debug tools',
    git = 'Enable git integration tools',
    ui = 'Enable Theme, Statusline, WinBar and other UI tools',
    util = 'Enable Useful tools',
    enhance = 'Enable Enhance tools including more UI and Util',
    ai = 'Enable AI tools',
    tex = 'Enable TeX tools',
    leetcode = 'Enable LeetCode',
    cmp = 'Select completion plugin',
    tab = 'Select tabline plugin',
    explorer = 'Select file explorer plugin',
    theme = 'Select theme',
    theme_style = 'Select style of the theme',
    bash_path = 'Set bash path in windows to use bash in terminal',
    gemini_api_key = 'Set gemini api key for AI tools',
    python_conda_command = 'Set command to find python env path of Conda',
    python_venv_command = 'Set command to find python env path of venv',
  }

  local function update_setting(option, result)
    -- if theme changed, reset theme_style
    if
      option == 'theme'
      and utils.find_value(result, selections.theme)
      and result ~= vim.g.options.theme
    then
      vim.g.theme_changed = true
      vim.api.nvim_set_var(
        'options',
        vim.tbl_extend('force', vim.g.options, { ['theme_style'] = '' })
      )
    end
    -- apply theme style when changed
    if
      option == 'theme_style'
      and not vim.g.theme_changed
      and not utils.find_value(vim.g.options.theme, {
        'everforest',
        'material',
        'onenord',
        'nordic',
      })
    then
      vim.cmd.colorscheme(result)
    end
    -- set option
    vim.api.nvim_set_var(
      'options',
      vim.tbl_extend('force', vim.g.options, { [option] = result })
    )
    utils.write_options()

    if vim.g.options[option] == result then
      vim.notify(
        option
          .. ' is set to '
          .. tostring(result)
          .. ', retart vim to apply changes',
        vim.log.levels.INFO,
        { title = 'Options Setting' }
      )
    end
  end

  local function set_select(option, items)
    local function selection_decode(selection)
      if selection == 'off' then
        return false
      elseif selection == 'on' then
        return true
      end
      return selection
    end
    vim.ui.select(items, {
      prompt = 'Select an option (' .. option .. '):',
      format_item = function(item)
        return item
      end,
    }, function(result)
      update_setting(option, selection_decode(result))
    end)
  end

  local function set_string(option)
    vim.ui.input(
      { prompt = 'Enter settings (' .. option .. '):' },
      function(input)
        update_setting(option, input)
      end
    )
  end

  vim.ui.select({
    'proxy',
    'language_support',
    'debug',
    'git',
    'ui',
    'util',
    'enhance',
    'ai',
    'tex',
    'leetcode',
    'cmp',
    'tab',
    'explorer',
    'theme',
    'theme_style',
    'bash_path',
    'gemini_api_key',
    'python_conda_command',
    'python_venv_command',
  }, {
    prompt = 'Select an option:',
    format_item = function(item)
      return string.format('%-22s', item) .. ' |  ' .. option_info[item]
    end,
  }, function(choice)
    -- set on or off
    if
      utils.find_value(choice, {
        'language_support',
        'debug',
        'git',
        'ui',
        'util',
        'enhance',
        'ai',
        'tex',
        'leetcode',
      })
    then
      set_select(choice, { 'on', 'off' })
    -- set one of the options
    elseif
      utils.find_value(
        choice,
        { 'cmp', 'tab', 'explorer', 'theme', 'theme_style' }
      )
    then
      set_select(choice, selections[choice])
    elseif
      utils.find_value(choice, {
        'proxy',
        'bash_path',
        'gemini_api_key',
        'python_conda_command',
        'python_venv_command',
      })
    then
      set_string(choice)
    end
  end)
end

return M
