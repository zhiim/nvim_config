return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

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

    local map = vim.keymap.set
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

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    -- set use_icons to true if you have a Nerd Font
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

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
        print 'Session does not exist'
        return
      end
    end, { desc = 'MiniSessions read Session' })
    map('n', '<Leader>msd', function()
      local session_name = get_session_name()
      if session_exist(session_name) then
        MiniSessions.delete(session_name, { force = true })
      else
        print 'Session does not exist'
        return
      end
    end, { desc = 'MiniSessions delete Session' })
    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
