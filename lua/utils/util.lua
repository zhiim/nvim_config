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
  elseif color_scheme == 'material' then
    return require('material.colors').main
  else
    return require('onedarkpro.helpers').get_colors()
  end
end

function util.get_gcc_path()
  local handle = io.popen 'where c++'
  if handle == nil then
    print 'get g++ path failed'
  else
    local result = handle:read '*a'
    handle:close()
    return result
  end
end

function util.gen_make_files()
  if vim.fn.executable 'cmake' == 0 then
    print 'cmake not found'
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
      vim.fn.system 'cmake -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -S . -B build -G "MinGW Makefiles"'
  else
    gen_result = vim.fn.system 'cmake -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -S . -B build'
  end
  print(vim.inspect(gen_result))
  vim.api.nvim_command 'LspRestart clangd'
end

return util
