local git_opts = vim.g.options.plugins.git

local graph_style = 'unicode'
if
  os.getenv 'TERM_PROGRAM' == 'WezTerm'
  or os.getenv 'TERM_PROGRAM' == 'ghostty'
  or os.getenv 'KITTY_WINDOW_ID'
then
  graph_style = 'kitty'
end

return {
  'NeogitOrg/neogit',
  init = function()
    -- Shim codediff.ui.view.create for legacy Neogit integration schema
    local ok, view = pcall(require, 'codediff.ui.view')
    if ok and view.create then
      local original_create = view.create
      local path = require 'codediff.core.path'

      view.create = function(session_config, filetype, on_ready)
        if session_config.mode == 'explorer' and not session_config.panel then
          session_config.panel = {
            name = 'explorer',
            data = session_config.explorer_data or {},
          }
          session_config.original = session_config.original or path.empty()
          session_config.modified = session_config.modified or path.empty()
        end
        return original_create(session_config, filetype, on_ready)
      end
    end
  end,
  lazy = true,
  enabled = vim.fn.has 'nvim-0.10' and git_opts.components.neogit
    or git_opts.enable_all,
  dependencies = {
    'm00qek/baleia.nvim',
  },
  cmd = 'Neogit',
  keys = {
    { '<leader>ng', '<cmd>Neogit<cr>', desc = 'Neogit UI' },
  },
  config = function()
    local neogit = require 'neogit'
    neogit.setup {
      graph_style = graph_style,
    }
  end,
}
