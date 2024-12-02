return { -- Collection of various small independent plugins/modules
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
}
