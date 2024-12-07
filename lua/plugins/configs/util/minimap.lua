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
      desc = 'MiniMap open map',
    },
    {
      '<leader>mmc',
      function()
        require('mini.map').close()
      end,
      mode = 'n',
      desc = 'MiniMap close map',
    },
    {
      '<leader>mmt',
      function()
        require('mini.map').toggle()
      end,
      mode = 'n',
      desc = 'MiniMap toggle map',
    },
    {
      '<leader>mmf',
      function()
        require('mini.map').toggle_focus()
      end,
      mode = 'n',
      desc = 'MiniMap toggle focus',
    },
    {
      '<leader>mmr',
      function()
        require('mini.map').refresh()
      end,
      mode = 'n',
      desc = 'MiniMap refresh map',
    },
    {
      '<leader>mms',
      function()
        require('mini.map').toggle_side()
      end,
      mode = 'n',
      desc = 'MiniMap toggle side',
    },
  },
}
