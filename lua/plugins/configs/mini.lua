local function get_session_name()
  local md5 = require 'utils.md5'
  local cwd = vim.fn.getcwd()
  local name = md5.sumhexa(cwd)
  name = 'session_' .. name
  return name
end

local function session_exist(session_dir, session_name)
  local session_file = session_dir .. '/' .. session_name
  return vim.fn.filereadable(session_file) == 1
end

return { -- Collection of various small independent plugins/modules
  {
    'echasnovski/mini.map',
    version = false,
    config = function()
      -- minimap settings
      local MiniMap = require 'mini.map'

      local minimap_opt

      minimap_opt = {
        integrations = {
          MiniMap.gen_integration.builtin_search(),
          MiniMap.gen_integration.gitsigns(),
          MiniMap.gen_integration.diagnostic(),
        },
        symbols = {
          encode = MiniMap.gen_encode_symbols.dot '4x2',
        },
      }

      MiniMap.setup(minimap_opt)
    end,
    keys = {
      {
        '<leader>mmo',
        function()
          require('mini.map').open()
        end,
        mode = 'n',
        desc = 'MiniMap Open Map',
      },
      {
        '<leader>mmc',
        function()
          require('mini.map').close()
        end,
        mode = 'n',
        desc = 'MiniMap Close Map',
      },
      {
        '<leader>mmt',
        function()
          require('mini.map').toggle()
        end,
        mode = 'n',
        desc = 'MiniMap Toggle map',
      },
      {
        '<leader>mmf',
        function()
          require('mini.map').toggle_focus()
        end,
        mode = 'n',
        desc = 'MiniMap Toggle focus',
      },
      {
        '<leader>mmr',
        function()
          require('mini.map').refresh()
        end,
        mode = 'n',
        desc = 'MiniMap Refresh Map',
      },
      {
        '<leader>mms',
        function()
          require('mini.map').toggle_side()
        end,
        mode = 'n',
        desc = 'MiniMap Toggle side',
      },
    },
  },
  {
    'echasnovski/mini.sessions',
    version = false,
    config = function()
      require('mini.sessions').setup {
        autowrite = false,
      }
    end,
    keys = {
      {
        '<leader>msw',
        function()
          local session_name = get_session_name()
          require('mini.sessions').write(session_name)
        end,
        mode = 'n',
        desc = 'MiniSessions Save Session',
      },
      {
        '<leader>msr',
        function()
          local mini_session = require 'mini.sessions'
          local session_name = get_session_name()
          if session_exist(mini_session.config.directory, session_name) then
            mini_session.read(session_name)
          else
            print 'Session does not exist for current directory'
            return
          end
        end,
        mode = 'n',
        desc = 'MiniSessions read Session',
      },
      {
        '<leader>msd',
        function()
          local mini_session = require 'mini.sessions'
          local session_name = get_session_name()
          if session_exist(mini_session.config.directory, session_name) then
            mini_session.delete(session_name, { force = true })
          else
            print 'Session does not exist for current directory'
            return
          end
        end,
        mode = 'n',
        desc = 'MiniSessions delete Session',
      },
    },
  },
}
