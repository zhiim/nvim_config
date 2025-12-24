--- name of current directory to use as session name
local function get_cwd_name()
  local cwd = vim.fn.getcwd()
  local name = string.lower(string.gsub(cwd, '[:/\\.]', '_'))
  return name
end

--- Check if session exists
local function session_exist(session_name)
  if session_name == nil or session_name == '' then
    session_name = 'latest'
  end
  local session_file = vim.fn.stdpath 'data'
    .. '/session/'
    .. get_cwd_name()
    .. '/'
    .. session_name
    .. '.json'
  return vim.fn.filereadable(session_file) == 1
end

return {
  'stevearc/resession.nvim',
  enabled = vim.fn.has 'nvim-0.8',
  dependencies = {
    {
      'stevearc/oil.nvim',
      cond = function()
        return vim.g.options.mode == 'IDE'
      end,
    },
    {
      'kevinhwang91/nvim-ufo',
      cond = function()
        return vim.g.options.mode == 'IDE'
      end,
    },
    {
      'luukvbaal/statuscol.nvim',
      cond = function()
        return vim.g.options.mode == 'IDE'
      end,
    },
  },
  keys = {
    {
      '<leader>rss',
      function()
        local default_session = require('resession').get_current()
        -- latest is reserved for auto-save
        if default_session == 'latest' then
          default_session = nil
        end
        vim.ui.input({
          prompt = 'Session name: ',
          default = default_session,
        }, function(session_name)
          if session_name == nil then
            return
          end
          if session_name == '' then
            session_name = default_session
            session_name = session_name or tostring(os.date '%Y-%m-%d-%H_%M_%S')
          end
          if session_exist(session_name) then
            local confirm = vim.fn.confirm(
              'Session "' .. session_name .. '" already exists. Overwrite?',
              '&Yes\n&No',
              2
            )
            if confirm ~= 1 then
              return
            end
          end
          require('resession').save(
            session_name,
            { dir = 'session/' .. get_cwd_name(), notify = true }
          )
        end)
      end,
      mode = 'n',
      desc = 'Resession session save',
    },
    {
      '<leader>rsr',
      function()
        require('resession').load(nil, { dir = '/session/' .. get_cwd_name() })
        vim.cmd 'silent! :e'
      end,
      mode = 'n',
      desc = 'Resession session read',
    },
    {
      '<leader>rsd',
      function()
        require('resession').delete(
          nil,
          { dir = '/session/' .. get_cwd_name(), notify = true }
        )
      end,
      mode = 'n',
      desc = 'Resession session delete',
    },
    {
      '<leader>rsc',
      function()
        local session_dir = vim.fn.stdpath 'data'
          .. '/session/'
          .. get_cwd_name()
        if #vim.fn.readdir(session_dir) == 0 then
          vim.notify(
            'No sessions to clear in ' .. get_cwd_name(),
            vim.log.levels.INFO
          )
          return
        end
        if vim.fn.delete(session_dir, 'rf') == 0 then
          vim.notify(
            'Cleared all sessions in ' .. get_cwd_name(),
            vim.log.levels.INFO
          )
        else
          vim.notify(
            'Failed to clear sessions in ' .. get_cwd_name(),
            vim.log.levels.ERROR
          )
        end
      end,
      mode = 'n',
      desc = 'Resession session clear all',
    },
  },
  init = function()
    -- Always save a special session named "latest" before exiting Neovim
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        require('resession').save(
          'latest',
          { dir = 'session/' .. get_cwd_name(), notify = false }
        )
      end,
    })
  end,
  config = function()
    require('resession').setup {
      -- override default filter to work with scope.nvim
      buf_filter = function(bufnr)
        local buftype = vim.bo[bufnr].buftype
        if buftype == 'help' then
          return true
        end
        if buftype ~= '' and buftype ~= 'acwrite' then
          return false
        end
        if vim.api.nvim_buf_get_name(bufnr) == '' then
          return false
        end

        -- this is required, since the default filter skips nobuflisted buffers
        return true
      end,
      extensions = { scope = {} }, -- add scope.nvim extension
    }
  end,
}
