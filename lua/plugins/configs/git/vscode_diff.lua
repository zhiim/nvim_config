local function run_git_async(args, opts, callback)
  opts = opts or {}

  -- On Windows, vim.system requires that cwd exists before running the command
  -- Validate the directory exists to provide a better error message
  if opts.cwd and vim.fn.isdirectory(opts.cwd) == 0 then
    callback('Directory does not exist: ' .. opts.cwd, nil)
    return
  end

  -- run the git command asynchronously, and capture the output to callback
  vim.system(vim.list_extend({ 'git' }, args), {
    cwd = opts.cwd,
    text = true,
  }, function(result)
    if result.code == 0 then
      callback(nil, result.stdout or '')
    else
      callback(result.stderr or 'Git command failed', nil)
    end
  end)
end

local function get_git_log(git_root, count, file_path, callback)
  count = count or 100 -- how many commits to retrieve
  local args = {
    'log',
    '--pretty=format:COMMIT:%h%d %s <%an> %ar',
    '--shortstat',
    '-n',
    tostring(count),
  }
  -- out format:
  -- COMMIT:e1b2ff3 diffview: set merge layout to diff3_mixed, Q Xu, 11 days ago
  --  1 file changed, 7 insertions(+)

  if file_path and file_path ~= '' then
    table.insert(args, '--')
    table.insert(args, file_path)
  end

  run_git_async(args, { cwd = git_root }, function(err, output)
    if err then
      callback(err, nil)
      return
    end

    local results = {}
    local lines = vim.split(output, '\n', { trimempty = true })

    local current_commit = nil

    for _, line in ipairs(lines) do
      local commit_info = line:match '^COMMIT:(.+)$'
      if commit_info then -- first line is commit info
        current_commit = commit_info
      elseif line:match '%d+ files? changed' and current_commit then
        -- files changed number
        local file_count = tonumber(line:match '(%d+) files? changed') or 0
        local file_word = file_count == 1 and 'file ' or 'files'
        -- format output line
        local formatted =
          string.format('%2d %s | %s', file_count, file_word, current_commit)
        table.insert(results, formatted)
        current_commit = nil
      end
    end

    callback(nil, results)
  end)
end

local function create_commit_log_window(lines, on_select_1, on_select_2, opts)
  opts = opts or {}
  local height = opts.height or math.min(#lines + 1, 15)

  -- create buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- buffer settings
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'git-commit-log'

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  vim.cmd('botright ' .. height .. 'split')
  vim.api.nvim_win_set_buf(0, buf)

  -- window settings
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].foldcolumn = '0'
  vim.wo[win].cursorline = true
  vim.wo[win].winfixheight = true
  vim.wo[win].winhighlight = 'Normal:NormalFloat,CursorLine:CursorLine'
  vim.wo[win].colorcolumn = ''

  vim.api.nvim_set_option_value(
    'winbar',
    'Git Logs. <i>: compare with previous commit; <I> compare with working tree',
    { win = win }
  )

  local keymap_opts = { buffer = buf, silent = true, nowait = true }

  -- compare current commit with previous
  vim.keymap.set('n', 'i', function()
    local line = vim.api.nvim_get_current_line()
    local hash = line:match '|%s*(%x+)'
    if hash then
      on_select_1(hash, buf)
    end
  end, keymap_opts)

  -- compare current commit with working tree
  vim.keymap.set('n', 'I', function()
    local line = vim.api.nvim_get_current_line()
    local hash = line:match '|%s*(%x+)'
    if hash then
      on_select_2(hash, buf)
    end
  end, keymap_opts)

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, keymap_opts)
end

return {
  'esmuellert/vscode-diff.nvim',
  enabled = vim.fn.has 'nvim-0.10',
  dependencies = { 'MunifTanjim/nui.nvim' },
  branch = 'next',
  cmd = 'CodeDiff',
  keys = {
    {
      '<leader>dvo',
      '<cmd>CodeDiff<cr>',
      mode = 'n',
      desc = 'Git Diffview open',
    },
    {
      '<leader>dvh',
      function()
        local git = require 'vscode-diff.git'

        local current_buf = vim.api.nvim_get_current_buf()
        local current_file = vim.api.nvim_buf_get_name(current_buf)
        local check_path = current_file ~= '' and current_file
          or vim.fn.getcwd()

        git.get_git_root(check_path, function(err_root, git_root)
          if err_root then
            vim.schedule(function()
              vim.notify(err_root, vim.log.levels.ERROR)
            end)
            return
          end

          get_git_log(git_root, 100, nil, function(err_log, lines)
            if err_log then
              vim.schedule(function()
                vim.notify(err_log, vim.log.levels.ERROR)
              end)
              return
            end

            if not lines or #lines == 0 then
              vim.schedule(function()
                vim.notify('No git history found', vim.log.levels.WARN)
              end)
              return
            end

            vim.schedule(function()
              create_commit_log_window(lines, function(commit)
                vim.cmd('CodeDiff ' .. commit .. '~1 ' .. commit)
              end, function(commit)
                vim.cmd('CodeDiff ' .. commit)
              end, { height = 12 })
            end)
          end)
        end)
      end,
      mode = 'n',
      desc = 'Git Diffview view current branch files history',
    },
    {
      '<leader>dvf',
      function()
        local git = require 'vscode-diff.git'

        local current_buf = vim.api.nvim_get_current_buf()
        local current_file = vim.api.nvim_buf_get_name(current_buf)

        if current_file == '' then
          vim.notify('Current buffer is not a file', vim.log.levels.ERROR)
          return
        end

        git.get_git_root(current_file, function(err_root, git_root)
          if err_root then
            vim.schedule(function()
              vim.notify(err_root, vim.log.levels.ERROR)
            end)
            return
          end

          local relative_path = git.get_relative_path(current_file, git_root)

          get_git_log(git_root, 100, relative_path, function(err_log, lines)
            if err_log then
              vim.schedule(function()
                vim.notify(err_log, vim.log.levels.ERROR)
              end)
              return
            end

            if not lines or #lines == 0 then
              vim.schedule(function()
                vim.notify(
                  'No git history found for this file',
                  vim.log.levels.WARN
                )
              end)
              return
            end

            local function focus_buf(buf)
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == buf then
                  vim.api.nvim_set_current_win(win)
                  return true
                end
              end
              return false
            end

            vim.schedule(function()
              create_commit_log_window(lines, function(commit, buf)
                -- first focus back to original buffer
                focus_buf(current_buf)
                vim.cmd('CodeDiff file ' .. commit .. '~1 ' .. commit)
                -- focus back to log buffer
                focus_buf(buf)
              end, function(commit, buf)
                focus_buf(current_buf)
                vim.cmd('CodeDiff file ' .. commit)
                focus_buf(buf)
              end, { height = 12 })
            end)
          end)
        end)
      end,
      mode = 'n',
      desc = 'Git Diffview view current file history',
    },
  },
  config = function()
    require('vscode-diff').setup {
      explorer = {
        position = 'left',
        width = 40,
        indent_markers = true,
        icons = {
          folder_closed = '󰉋',
          folder_open = '󰝰',
        },
      },

      keymaps = {
        view = {
          quit = 'q',
          toggle_explorer = '<leader>b',
          next_hunk = ']h',
          prev_hunk = '[h',
          next_file = ']f',
          prev_file = '[f',
          diff_get = 'do',
          diff_put = 'dp',
        },
        explorer = {
          select = '<CR>',
          hover = 'K',
          refresh = 'R',
          toggle_view_mode = 'i',
        },
      },
    }
  end,
}
