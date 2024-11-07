local M = {}

function M.get_session_name()
  local md5 = require 'utils.md5'
  local cwd = vim.fn.getcwd()
  local name = md5.sumhexa(cwd)
  name = 'session_' .. name
  return name
end

function M.session_exist(session_dir, session_name)
  local session_file = session_dir .. '/' .. session_name
  return vim.fn.filereadable(session_file) == 1
end

return M
