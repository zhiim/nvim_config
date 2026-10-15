local git_opts = vim.g.options.plugins.git
local commit_to_diff = nil
local previous_configs = {}
local codediff_tabs = {}
local suspended_overlays = {}

return {
  'echasnovski/mini.diff',
  enabled = git_opts.components.mini_diff or git_opts.enable_all,
  event = 'VeryLazy',
  version = false,
  config = function(_, opts)
    require('mini.diff').setup(opts)

    local function is_file_buf(buf)
      return vim.api.nvim_buf_is_valid(buf)
        and vim.api.nvim_buf_is_loaded(buf)
        and vim.bo[buf].buftype == ''
        and vim.api.nvim_buf_get_name(buf) ~= ''
    end

    local function in_codediff()
      return codediff_tabs[vim.api.nvim_get_current_tabpage()] == true
    end

    local function sync_overlays()
      local diff = require 'mini.diff'
      if in_codediff() then
        -- Overlay extmarks belong to buffers, including files shared with CodeDiff.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local data = diff.get_buf_data(buf)
          if data and data.overlay then
            suspended_overlays[buf] = true
            diff.toggle_overlay(buf)
          end
        end
      else
        for buf in pairs(suspended_overlays) do
          local data = vim.api.nvim_buf_is_valid(buf) and diff.get_buf_data(buf)
          if data and not data.overlay then
            diff.toggle_overlay(buf)
          end
          suspended_overlays[buf] = nil
        end
      end
    end

    local function git(cwd, args)
      local command = { 'git', '-C', cwd }
      vim.list_extend(command, args)
      return vim.system(command, { text = false }):wait()
    end

    local function diff_show(buf, commit)
      local path = vim.api.nvim_buf_get_name(buf)
      if path == '' or vim.bo[buf].buftype ~= '' then
        return false, 'Current buffer must be a file'
      end

      local dir = vim.fs.dirname(path)
      local root_result = git(dir, { 'rev-parse', '--show-toplevel' })
      if root_result.code ~= 0 then
        return false, 'Current file is not inside a Git repository'
      end
      local root = vim.trim(root_result.stdout)
      local relative_path = vim.fs.relpath(root, path)
      if not relative_path then
        return false, 'Current file is outside the Git worktree'
      end

      if type(commit) ~= 'string' or commit == '' then
        commit = 'HEAD'
      end

      local rev = git(
        root,
        { 'rev-parse', '--verify', '--end-of-options', commit .. '^{commit}' }
      )
      if rev.code ~= 0 then
        return false, 'Invalid commit: ' .. commit
      end
      local hash = vim.trim(rev.stdout)
      local entry = git(
        root,
        { 'ls-tree', '-rz', hash, '--', ':(literal)' .. relative_path }
      )
      if entry.code ~= 0 then
        return false, 'Could not inspect commit: ' .. commit
      end
      local kind = entry.stdout:match '^%d+ (%w+) [%x]+\t'
      if entry.stdout ~= '' and kind ~= 'blob' then
        return false, 'Not a file at commit: ' .. relative_path
      end

      local text = '' -- A file absent from the commit is entirely added in the worktree.
      if kind == 'blob' then
        local blob = git(root, { 'show', hash .. ':' .. relative_path })
        if blob.code ~= 0 then
          return false, 'Could not read file at commit: ' .. relative_path
        end
        text = blob.stdout
      end
      if text:find('\0', 1, true) then
        return false, 'Cannot show a binary file with mini.diff'
      end

      local diff = require 'mini.diff'
      if previous_configs[buf] == nil then
        local data = diff.get_buf_data(buf)
        previous_configs[buf] = {
          config = vim.b[buf].minidiff_config,
          enabled = data ~= nil,
          overlay = data and data.overlay or false,
        }
      end
      diff.disable(buf)
      local config = vim.deepcopy(previous_configs[buf].config or {})
      config.source = {
        name = 'commit ' .. hash,
        attach = function(id)
          diff.set_ref_text(id, text)
        end,
      }
      vim.b[buf].minidiff_config = config
      diff.enable(buf)
      diff.toggle_overlay(buf)

      return true, 'mini.diff overlay enabled for ' .. commit
    end

    local function diff_reset(buf)
      local previous = previous_configs[buf]

      local diff = require 'mini.diff'
      diff.disable(buf)
      vim.b[buf].minidiff_config = previous.config
      previous_configs[buf] = nil
      suspended_overlays[buf] = nil
      if previous.enabled then
        diff.enable(buf)
        if previous.overlay then
          diff.toggle_overlay(buf)
        end
      end
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = { 'CodeDiffOpen', 'CodeDiffClose' },
      callback = function(args)
        codediff_tabs[args.data.tabpage] = args.match == 'CodeDiffOpen' or nil
        -- CodeDiffClose fires before cleanup; BufEnter can precede CodeDiffOpen.
        vim.schedule(sync_overlays)
      end,
    })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'TabEnter' }, {
      callback = vim.schedule_wrap(function()
        sync_overlays()
        if commit_to_diff == nil or in_codediff() then
          return
        end
        local buf = vim.api.nvim_get_current_buf()
        if is_file_buf(buf) and previous_configs[buf] == nil then
          diff_show(buf, commit_to_diff)
        end
      end),
    })

    vim.api.nvim_create_autocmd('BufUnload', {
      callback = function(args)
        suspended_overlays[args.buf] = nil
        local previous = previous_configs[args.buf]
        if not previous then
          return
        end
        vim.b[args.buf].minidiff_config = previous.config
        previous_configs[args.buf] = nil
      end,
    })

    vim.keymap.set('n', '<leader>md', function()
      local cur_buf = vim.api.nvim_get_current_buf()
      if commit_to_diff == nil then
        if in_codediff() then
          vim.notify(
            'mini.diff overlay is hidden in CodeDiff',
            vim.log.levels.INFO
          )
          return
        end
        vim.ui.input({
          prompt = 'Commit ID: (current branch by default)',
        }, function(commit)
          if commit ~= nil then
            if not is_file_buf(cur_buf) then
              vim.notify('Not a file buffer', vim.log.levels.ERROR)
              return
            end
            local ok, msg = diff_show(cur_buf, commit)
            if not ok then
              vim.notify(msg, vim.log.levels.ERROR)
            else
              commit_to_diff = commit
              vim.notify(msg, vim.log.levels.INFO)
            end
          end
        end)
      else
        commit_to_diff = nil
        for buf in pairs(previous_configs) do
          if vim.api.nvim_buf_is_valid(buf) then
            diff_reset(buf)
          end
        end
        sync_overlays()
        vim.notify('mini.diff state restored', vim.log.levels.INFO)
      end
    end, { desc = 'Git toggle mini.diff overlay on commit' })
  end,
  opts = {
    view = {
      style = 'sign',
      signs = {
        add = '▎',
        change = '▎',
        delete = '',
      },
    },
    options = {
      algorithm = 'histogram',
      indent_heuristic = true,
      linematch = 40,
      wrap_goto = false,
    },
  },
}
