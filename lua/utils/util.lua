local utils = {}

--- get palette according to color_scheme
function utils.get_palette()
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
      local palette = require('github-theme.palette').load(vim.g.options.scheme_style)
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
  local color_scheme = vim.g.options.color_scheme or 'onedark'
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
    gen_result = vim.fn.system 'cmake -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE -S . -B build'
  end
  vim.notify(gen_result, vim.log.levels.INFO, { title = 'Generate build files' })
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

return utils
