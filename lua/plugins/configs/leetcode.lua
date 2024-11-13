local leet_arg = 'leet'

if vim.g.options.enable_leetcode then
  return {
    'kawre/leetcode.nvim',
    lazy = leet_arg ~= vim.fn.argv()[1], -- lazy load
    cmd = 'Leet',
    build = ':TSUpdate html',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim', -- required by telescope
      'MunifTanjim/nui.nvim',

      -- optional
      'nvim-treesitter/nvim-treesitter',
      -- 'rcarriga/nvim-notify',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      -- configuration goes here
      arg = leet_arg,
      cn = {
        enabled = true,
      },
      storage = {
        home = 'C:\\Users\\user\\OneDrive\\Apps\\leetcode',
      },
      hooks = {
        ['enter'] = function()
          vim.cmd 'Copilot disable'
        end,
        ['leave'] = function()
          vim.cmd 'Copilot enable'
        end,
      },
    },
  }
else
  return {}
end
