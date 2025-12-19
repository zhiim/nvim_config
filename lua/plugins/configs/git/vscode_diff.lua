local function run_git_async(args, opts, callback)
  opts = opts or {}

  -- Use vim.system if available (Neovim 0.10+)
  if vim.system then
    -- On Windows, vim.system requires that cwd exists before running the command
    -- Validate the directory exists to provide a better error message
    if opts.cwd and vim.fn.isdirectory(opts.cwd) == 0 then
      callback('Directory does not exist: ' .. opts.cwd, nil)
      return
    end

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
  else
    -- Fallback to vim.loop.spawn for older Neovim versions
    -- Validate the directory exists to provide a better error message
    if opts.cwd and vim.fn.isdirectory(opts.cwd) == 0 then
      callback('Directory does not exist: ' .. opts.cwd, nil)
      return
    end

    local stdout_data = {}
    local stderr_data = {}

    local handle
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    ---@diagnostic disable-next-line: missing-fields
    handle = vim.loop.spawn('git', {
      args = args,
      cwd = opts.cwd,
      stdio = { nil, stdout, stderr },
    }, function(code)
      if stdout then
        stdout:close()
      end
      if stderr then
        stderr:close()
      end
      if handle then
        handle:close()
      end

      vim.schedule(function()
        if code == 0 then
          callback(nil, table.concat(stdout_data))
        else
          callback(table.concat(stderr_data) or 'Git command failed', nil)
        end
      end)
    end)

    if not handle then
      callback('Failed to spawn git process', nil)
      return
    end

    if stdout then
      stdout:read_start(function(err, data)
        if err then
          callback(err, nil)
        elseif data then
          table.insert(stdout_data, data)
        end
      end)
    end

    if stderr then
      stderr:read_start(function(err, data)
        if err then
          callback(err, nil)
        elseif data then
          table.insert(stderr_data, data)
        end
      end)
    end
  end
end

local function get_log(git_root, count, file_path, callback)
  count = count or 100
  local args = { 'log', '--oneline', '-n', tostring(count) }

  if file_path and file_path ~= '' then
    table.insert(args, '--')
    table.insert(args, file_path)
  end

  run_git_async(args, { cwd = git_root }, function(err, output)
    if err then
      callback(err, nil)
      return
    end

    local lines = vim.split(output, '\n')
    if lines[#lines] == '' then
      table.remove(lines, #lines)
    end

    callback(nil, lines)
  end)
end

return {
  'esmuellert/vscode-diff.nvim',
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

          get_log(git_root, 100, nil, function(err_log, lines)
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
              -- Create split window at bottom
              vim.cmd 'botright 10new'
              local buf = vim.api.nvim_get_current_buf()

              -- Set content
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

              -- Buffer settings
              vim.bo[buf].buftype = 'nofile'
              vim.bo[buf].bufhidden = 'wipe'
              vim.bo[buf].swapfile = false
              vim.bo[buf].modifiable = false
              vim.bo[buf].filetype = 'vscode-diff-commit-list' -- Use git syntax highlighting if available

              -- Keymap for selection
              vim.keymap.set('n', '<CR>', function()
                local line = vim.api.nvim_get_current_line()
                local commit = line:match '^(%S+)'
                if commit then
                  -- Compare commit~1 (parent) vs commit to see changes introduced by commit
                  vim.cmd('CodeDiff ' .. commit .. '~1 ' .. commit)
                end
              end, {
                buffer = buf,
                noremap = true,
                silent = true,
              })

              vim.keymap.set(
                'n',
                'q',
                ':close<CR>',
                { buffer = buf, noremap = true, silent = true }
              )

              vim.notify(
                "Press <CR> on a commit to view diff, 'q' to close. Showing last 100 commits.",
                vim.log.levels.INFO
              )

              -- Default: Open diff for latest commit in the list
              local first_line = lines[1]
              local commit = first_line:match '^(%S+)'
              if commit then
                vim.cmd('CodeDiff ' .. commit .. '~1 ' .. commit)
              end
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

        local function handle_git_diff(revision, revision2, file_path_override)
          local current_file = file_path_override
            or vim.api.nvim_buf_get_name(0)

          if current_file == '' then
            vim.notify('Current buffer is not a file', vim.log.levels.ERROR)
            return
          end

          -- Determine filetype from current buffer (sync operation, no git involved)
          local filetype = vim.bo[0].filetype
          if not filetype or filetype == '' then
            filetype = vim.filetype.match { filename = current_file } or ''
          end

          -- Async chain: get_git_root -> resolve_revision -> get_file_content -> render_diff
          git.get_git_root(current_file, function(err_root, git_root)
            if err_root then
              vim.schedule(function()
                vim.notify(err_root, vim.log.levels.ERROR)
              end)
              return
            end

            local relative_path = git.get_relative_path(current_file, git_root)

            git.resolve_revision(
              revision,
              git_root,
              function(err_resolve, commit_hash)
                if err_resolve then
                  vim.schedule(function()
                    vim.notify(err_resolve, vim.log.levels.ERROR)
                  end)
                  return
                end

                if revision2 then
                  -- Compare two revisions
                  git.resolve_revision(
                    revision2,
                    git_root,
                    function(err_resolve2, commit_hash2)
                      if err_resolve2 then
                        vim.schedule(function()
                          vim.notify(err_resolve2, vim.log.levels.ERROR)
                        end)
                        return
                      end

                      vim.schedule(function()
                        local view = require 'vscode-diff.render.view'
                        ---@type SessionConfig
                        local session_config = {
                          mode = 'standalone',
                          git_root = git_root,
                          original_path = relative_path,
                          modified_path = relative_path,
                          original_revision = commit_hash,
                          modified_revision = commit_hash2,
                        }
                        view.create(session_config, filetype)
                      end)
                    end
                  )
                else
                  -- Compare revision vs working tree
                  vim.schedule(function()
                    local view = require 'vscode-diff.render.view'
                    ---@type SessionConfig
                    local session_config = {
                      mode = 'standalone',
                      git_root = git_root,
                      original_path = relative_path,
                      modified_path = relative_path,
                      original_revision = commit_hash,
                      modified_revision = 'WORKING',
                    }
                    view.create(session_config, filetype)
                  end)
                end
              end
            )
          end)
        end

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

          get_log(git_root, 100, relative_path, function(err_log, lines)
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

            vim.schedule(function()
              -- Create split window at bottom
              vim.cmd 'botright 10new'
              local buf = vim.api.nvim_get_current_buf()

              -- Set content
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

              -- Buffer settings
              vim.bo[buf].buftype = 'nofile'
              vim.bo[buf].bufhidden = 'wipe'
              vim.bo[buf].swapfile = false
              vim.bo[buf].modifiable = false
              vim.bo[buf].filetype = 'git' -- Use git syntax highlighting if available

              -- Keymap for selection
              vim.keymap.set('n', '<CR>', function()
                local line = vim.api.nvim_get_current_line()
                local commit = line:match '^(%S+)'
                if commit then
                  -- Compare commit~1 (parent) vs commit for this SPECIFIC file
                  handle_git_diff(commit .. '~1', commit, current_file)
                end
              end, { buffer = buf, noremap = true, silent = true })

              vim.keymap.set(
                'n',
                'q',
                ':close<CR>',
                { buffer = buf, noremap = true, silent = true }
              )

              vim.notify(
                "Press <CR> on a commit to view file diff, 'q' to close.",
                vim.log.levels.INFO
              )

              -- Default: Open diff for latest commit in the list
              local first_line = lines[1]
              local commit = first_line:match '^(%S+)'
              if commit then
                handle_git_diff(commit .. '~1', commit, current_file)
              end
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
