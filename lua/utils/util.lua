local utils = {}

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
  utils.with_file(vim.g.cache_path, 'r', function(file)
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
  utils.with_file(vim.g.cache_path, 'w+', function(file)
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
    stylua = '.stylua.toml',
  }
  local options = {
    'ruff',
    'yamllint',
    'clang_format',
    'stylua',
  }
  vim.ui.select(options, {
    prompt = 'Select a linter or formatter:',
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if not utils.find_value(choice, options) then
      return
    end
    local cwd_file = vim.fn.getcwd() .. '/' .. config_name[choice]
    local config_file = vim.fn.stdpath 'config'
      .. '/config_files/'
      .. config_name[choice]
    utils.copy_file(config_file, cwd_file)
    vim.api.nvim_command 'LspRestart'
  end)
end

return utils
