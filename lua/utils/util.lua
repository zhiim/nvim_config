local utils = {}

--- get palette according to color_scheme
function utils.get_palette()
  if not vim.g.options.ui then
    return {
      red = '#E06C75',
      yellow = '#E5C07B',
      blue = '#61AFEF',
      orange = '#D19A66',
      green = '#98C379',
      magenta = '#C678DD',
      cyan = '#56B6C2',
    }
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
  }
  local color_scheme = vim.g.options.theme
  return palette_funcs[color_scheme]()
end

--- get the path of g++ compiler
function utils.get_gcc_path()
  local handle = io.popen 'where c++'
  if handle == nil then
    print 'get g++ path failed'
  else
    local result = handle:read '*a'
    handle:close()
    return result
  end
end

--- generate cmake build files with compile_commands.json
function utils.gen_make_files()
  if vim.fn.executable 'cmake' == 0 then
    vim.notify('cmake not found', vim.log.levels.ERROR)
    return
  end
  -- create build dir
  if vim.fn.isdirectory 'build' == 0 then
    vim.fn.mkdir 'build'
  end
  -- generate build files
  local gen_result
  if vim.fn.has 'win32' == 1 then
    gen_result =
      vim.fn.system 'cmake -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -S . -B build -G "Unix Makefiles"'
  else
    gen_result =
      vim.fn.system 'cmake -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -S . -B build'
  end
  vim.notify(
    gen_result,
    vim.log.levels.INFO,
    { title = 'Generate build files' }
  )
  vim.api.nvim_command 'LspRestart clangd'
end

--- Execute function with open file
---@param file string path to file to interact with
---@param mode openmode the mode in which to open the file
---@param callback fun(fd:file*) the callback to execute with the opened file
---@param on_error? fun(err:string) the callback to execute if unable to open the file
function utils.with_file(file, mode, callback, on_error)
  local fd, errmsg = io.open(file, mode)
  if fd then
    callback(fd)
    fd:close()
  elseif errmsg and on_error then
    on_error(errmsg)
  end
end

-- read options from cache
function utils.read_options()
  local cache_path = vim.fn.stdpath 'config' .. '/cache'
  utils.with_file(cache_path, 'r', function(file)
    -- read cache into options
    vim.g.options = vim.json.decode(file:read '*a')
  end, function(err)
    vim.notify(
      'Error reading cache file: ' .. err,
      vim.log.levels.ERROR,
      { title = 'Cache Read' }
    )
  end)
end

-- write options to cache
function utils.write_options()
  local cache_path = vim.fn.stdpath 'config' .. '/cache'
  utils.with_file(cache_path, 'w+', function(file)
    -- write default options into cache
    file:write(vim.json.encode(vim.g.options))
  end, function(err)
    vim.notify(
      'Error writing cache file: ' .. err,
      vim.log.levels.ERROR,
      { title = 'Cache Write' }
    )
  end)
end

function utils.find_value(value_to_find, my_table)
  local found = false
  for _, value in ipairs(my_table) do -- using ipairs since it's an array-like table
    if value == value_to_find then
      found = true
      break -- Exit the loop once the value is found
    end
  end
  return found
end

-- set user options and write to cache
function utils.set_options()
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
    tab = { 'barbar', 'bufferline', 'tabby' },
    explorer = { 'nvimtree', 'neotree' },
    theme = {
      'github',
      'tokyonight',
      'catppuccin',
      'nightfox',
      'kanagawa',
      'onedark',
      'material',
      'onenord',
      'nordic',
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
    if option == 'theme_style' and not vim.g.theme_changed then
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
      utils.find_value(choice, { 'tab', 'explorer', 'theme', 'theme_style' })
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

function utils.pyright_type_checking(mode)
  local clients = vim.lsp.get_clients { name = 'basedpyright' }
  for _, client in pairs(clients) do
    client.config.settings.basedpyright.analysis.typeCheckingMode = mode
    client.notify(
      'workspace/didChangeConfiguration',
      { settings = client.config.settings }
    )
    vim.notify(
      'Pyright type checking is set to '
        .. client.config.settings.basedpyright.analysis.typeCheckingMode,
      vim.log.levels.INFO,
      { title = 'Pyright Type Checking' }
    )
  end
end

function utils.get_hl(name)
  local function int_to_hex(int)
    if int == nil then
      return 'None'
    end
    return string.format('#%06X', int)
  end

  local hi = vim.api.nvim_get_hl(0, {
    name = name,
    link = false,
  })

  return {
    fg = int_to_hex(hi.fg),
    bg = int_to_hex(hi.bg),
    italic = hi.italic,
  }
end

function utils.copy_file(source, destination)
  local input_file = io.open(source, 'rb')
  if not input_file then
    error('Could not open source file: ' .. source)
  end

  local output_file = io.open(destination, 'wb')
  if not output_file then
    error('Could not open destination file: ' .. destination)
  end

  local content = input_file:read '*all'
  output_file:write(content)

  input_file:close()
  output_file:close()
end

function utils.lint_format_config()
  local config_name = {
    ruff = 'ruff.toml',
    yamllint = '.yamllint',
    clang_format = '.clang-format',
  }
  vim.ui.select({
    'ruff',
    'yamllint',
    'clang_format',
  }, {
    prompt = 'Select a linter or formatter:',
    format_item = function(item)
      return item
    end,
  }, function(choice)
    local cwd_file = vim.fn.getcwd() .. '/' .. config_name[choice]
    local config_file = vim.fn.stdpath 'config'
      .. '/lua/utils/config_files/'
      .. config_name[choice]
    utils.copy_file(config_file, cwd_file)
    vim.api.nvim_command 'LspRestart'
  end)
end

return utils
