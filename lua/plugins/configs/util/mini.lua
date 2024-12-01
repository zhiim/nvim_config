local session_dir = vim.fn.stdpath 'data' .. '/session'

--- md5 hash of current directory to use as session name
local function get_session_name()
  local md5 = require 'utils.md5'
  local cwd = vim.fn.getcwd()
  local name = md5.sumhexa(cwd)
  name = 'session_' .. name
  return name
end

--- Check if session exists
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
        window = {
          focusable = true,
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
        directory = session_dir,
        hooks = {
          -- Before successful action
          -- work with scope.nvim to save/restore tab-scoped buffers
          pre = {
            write = function()
              require('scope.core').on_tab_leave()
              require('scope.core').on_tab_enter()
              local cache = require('scope.session').serialize_state()

              require('utils.util').with_file(session_dir .. '/' .. get_session_name() .. '_cache', 'w+', function(file)
                -- write default options into cache
                file:write(cache)
              end, function(err)
                vim.notify('Error writing cache file: ' .. err, vim.log.levels.ERROR, { title = 'Cache Write' })
              end)
            end,

            read = function()
              local cache = ''
              require('utils.util').with_file(session_dir .. '/' .. get_session_name() .. '_cache', 'r', function(file)
                -- read cache into options
                cache = file:read '*a'
              end, function(err)
                vim.notify('Error reading cache file: ' .. err, vim.log.levels.ERROR, { title = 'Cache Read' })
              end)

              require('scope.session').deserialize_state(cache)
            end,
          },
        },
      }
    end,
    keys = {
      {
        '<leader>mss',
        function()
          local session_name = get_session_name()
          require('mini.sessions').write(session_name)
        end,
        mode = 'n',
        desc = 'MiniSessions Session Save',
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
        desc = 'MiniSessions Session read',
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
        desc = 'MiniSessions Session delete',
      },
    },
  },
}
