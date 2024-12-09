--- name of current directory to use as session name
local function get_session_name()
  local cwd = vim.fn.getcwd()
  local name = string.lower(string.gsub(cwd, '[:/\\]', '_'))
  return name
end

--- Check if session exists
local function session_exist(session_name)
  local session_file = vim.fn.stdpath 'data'
    .. '/session/'
    .. session_name
    .. '.json'
  return vim.fn.filereadable(session_file) == 1
end

return {
  'stevearc/resession.nvim',
  enabled = vim.fn.has 'nvim-0.7.2',
  dependencies = {
    { 'stevearc/oil.nvim' },
    { 'kevinhwang91/nvim-ufo' },
    { 'luukvbaal/statuscol.nvim' },
  },
  keys = {
    {
      '<leader>rss',
      function()
        local session_name = get_session_name()
        require('resession').save(session_name)
      end,
      mode = 'n',
      desc = 'Resession session save',
    },
    {
      '<leader>rsr',
      function()
        local session_name = get_session_name()
        if session_exist(session_name) then
          require('resession').load(session_name)
          vim.cmd 'silent! :e'
        else
          vim.notify(
            'Session does not exist for current directory',
            vim.log.levels.INFO,
            { title = 'Resession' }
          )
        end
      end,
      mode = 'n',
      desc = 'Resession session read',
    },
    {
      '<leader>rsd',
      function()
        local session_name = get_session_name()
        if session_exist(session_name) then
          require('resession').delete(session_name)
        else
          vim.notify(
            'Session does not exist for current directory',
            vim.log.levels.INFO,
            { title = 'Resession' }
          )
        end
      end,
      mode = 'n',
      desc = 'Resession session delete',
    },
  },
  opts = {
    -- override default filter
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
  },
}
