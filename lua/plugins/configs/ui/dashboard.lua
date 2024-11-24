local logo = [[
    ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
    ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
    ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
    ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
    ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
    ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
]]
logo = string.rep('\n', 8) .. logo .. '\n\n'

local config_center = {
  {
    icon = '  ',
    desc = 'Read Saved Session',
    key = 's',
    action = "lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Leader>msr', true, false, true), 'm', true)",
  },
  {
    icon = '  ',
    desc = 'Recent Files',
    key = 'r',
    action = 'Telescope oldfiles',
  },
  {
    icon = '  ',
    desc = 'Find File',
    key = 'f',
    action = 'Telescope find_files',
  },
  {
    icon = '  ',
    desc = 'Find Word',
    key = 'w',
    action = 'Telescope live_grep',
  },
  {
    icon = '  ',
    desc = 'New Files',
    key = 'e',
    action = 'ene | startinsert',
  },
  {
    icon = '  ',
    desc = 'Quit',
    key = 'q',
    action = function()
      vim.api.nvim_input '<cmd>qa<cr>'
    end,
  },
}

for _, button in ipairs(config_center) do
  button.desc = button.desc .. string.rep(' ', 32 - #button.desc)
  button.key_format = '  %s'
  button.key_hl = 'Number'
end

return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
      theme = 'doom',
      config = {
        header = vim.split(logo, '\n'),
        center = config_center,
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
        end,
      },
    }
  end,
}
