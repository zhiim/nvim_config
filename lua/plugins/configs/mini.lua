local map = vim.keymap.set

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

      -- minimap key mappings

      map('n', '<Leader>mmo', function()
        MiniMap.open()
      end, { desc = 'MiniMap Open Map' })
      map('n', '<Leader>mmc', function()
        MiniMap.close()
      end, { desc = 'MiniMap Close Map' })
      map('n', '<Leader>mmt', function()
        MiniMap.toggle()
      end, { desc = 'MiniMap Toggle map' })
      map('n', '<Leader>mmf', function()
        MiniMap.toggle_focus()
      end, { desc = 'MiniMap Toggle focus' })
      map('n', '<Leader>mmr', function()
        MiniMap.refresh()
      end, { desc = 'MiniMap Refresh Map' })
      map('n', '<Leader>mms', function()
        MiniMap.toggle_side()
      end, { desc = 'MiniMap Toggle side' })
    end,
  },
  {
    'echasnovski/mini.sessions',
    version = false,
    config = function()
      require('mini.sessions').setup {
        autowrite = false,
      }
      -- mappings for mini sessions
      local function get_session_name()
        local md5 = require 'libs.md5'
        local cwd = vim.fn.getcwd()
        local name = md5.sumhexa(cwd)
        name = 'session_' .. name
        return name
      end
      local function session_exist(session_name)
        local session_dir = MiniSessions.config.directory
        local session_file = session_dir .. '/' .. session_name
        return vim.fn.filereadable(session_file) == 1
      end
      map('n', '<Leader>msw', function()
        local session_name = get_session_name()
        MiniSessions.write(session_name)
      end, { desc = 'MiniSessions Save Session' })
      map('n', '<Leader>msr', function()
        local session_name = get_session_name()
        if session_exist(session_name) then
          MiniSessions.read(session_name)
        else
          print 'Session does not exist for current directory'
          return
        end
      end, { desc = 'MiniSessions read Session' })
      map('n', '<Leader>msd', function()
        local session_name = get_session_name()
        if session_exist(session_name) then
          MiniSessions.delete(session_name, { force = true })
        else
          print 'Session does not exist for current directory'
          return
        end
      end, { desc = 'MiniSessions delete Session' })
    end,
  },
}
