local M = {}

function M.change_settings()
  local n = require 'nui-components'

  local cur_tab = n.create_signal {
    active_tab = '',
  }
end

return M
