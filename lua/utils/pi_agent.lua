local M = {}

local uv = vim.uv or vim.loop
local MAX_RESPONSE_BYTES = 64 * 1024

local function notify(message, level)
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO, { title = 'Pi Agent' })
  end)
end

local function runtime_directory()
  if vim.env.XDG_RUNTIME_DIR and vim.env.XDG_RUNTIME_DIR ~= '' then
    return vim.fs.joinpath(vim.env.XDG_RUNTIME_DIR, 'pi-nvim')
  end

  local passwd = uv.os_get_passwd()
  local uid = passwd and passwd.uid or 'user'
  return vim.fs.joinpath('/tmp', 'pi-nvim-' .. tostring(uid))
end

local function socket_path()
  local cwd = uv.fs_realpath(vim.fn.getcwd())
    or vim.fs.normalize(vim.fn.fnamemodify(vim.fn.getcwd(), ':p'))
  local project_id = vim.fn.sha256(cwd):sub(1, 16)
  return vim.fs.joinpath(runtime_directory(), project_id .. '.sock')
end

local function close_pipe(pipe)
  if pipe and not pipe:is_closing() then
    pipe:close()
  end
end

local function leave_visual_mode()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' or mode == 'V' or mode == '\22' then
    local escape = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(escape, 'nx', false)
  end
end

local function send_payload(payload)
  local pipe = uv.new_pipe(false)
  if not pipe then
    notify('Unable to create a Unix socket client', vim.log.levels.ERROR)
    return
  end

  local response = ''
  local target = socket_path()

  pipe:connect(target, function(connect_error)
    if connect_error then
      close_pipe(pipe)
      notify(
        ('Unable to connect to Pi: %s\nEnsure Pi and Neovim use the same working directory and nvim-bridge is loaded.'):format(
          connect_error
        ),
        vim.log.levels.ERROR
      )
      return
    end

    pipe:read_start(function(read_error, chunk)
      if read_error then
        close_pipe(pipe)
        notify(
          'Failed to read the Pi response: ' .. read_error,
          vim.log.levels.ERROR
        )
        return
      end

      if not chunk then
        close_pipe(pipe)
        return
      end

      response = response .. chunk
      if #response > MAX_RESPONSE_BYTES then
        close_pipe(pipe)
        notify('The Pi response exceeded the size limit', vim.log.levels.ERROR)
        return
      end

      local newline = response:find('\n', 1, true)
      if not newline then
        return
      end

      local response_line = response:sub(1, newline - 1)
      close_pipe(pipe)

      vim.schedule(function()
        local ok, result = pcall(vim.json.decode, response_line)
        if not ok or type(result) ~= 'table' then
          vim.notify(
            'Pi returned an invalid response',
            vim.log.levels.ERROR,
            { title = 'Pi Agent' }
          )
        elseif result.ok then
          leave_visual_mode()
          vim.notify(
            'Selection loaded into the Pi editor',
            nil,
            { title = 'Pi Agent' }
          )
        else
          vim.notify(
            'Pi rejected the selection: ' .. tostring(result.error),
            vim.log.levels.ERROR,
            { title = 'Pi Agent' }
          )
        end
      end)
    end)

    pipe:write(vim.json.encode(payload) .. '\n', function(write_error)
      if write_error then
        close_pipe(pipe)
        notify(
          'Failed to send the selection to Pi: ' .. write_error,
          vim.log.levels.ERROR
        )
      end
    end)
  end)
end

function M.send_visual_selection()
  local buffer = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buffer)
  if file_path == '' then
    vim.notify(
      'The current buffer has no file path',
      vim.log.levels.ERROR,
      { title = 'Pi Agent' }
    )
    return
  end

  file_path = uv.fs_realpath(file_path)
    or vim.fs.normalize(vim.fn.fnamemodify(file_path, ':p'))

  local visual_start = vim.fn.getpos 'v'
  local visual_end = vim.fn.getpos '.'
  local visual_mode = vim.fn.mode()
  local content =
    vim.fn.getregion(visual_start, visual_end, { type = visual_mode })

  if #content == 0 then
    vim.notify(
      'No code is selected',
      vim.log.levels.WARN,
      { title = 'Pi Agent' }
    )
    return
  end

  send_payload {
    type = 'selection',
    path = file_path,
    startLine = math.min(visual_start[2], visual_end[2]),
    endLine = math.max(visual_start[2], visual_end[2]),
    content = table.concat(content, '\n') .. '\n',
  }
end

return M
