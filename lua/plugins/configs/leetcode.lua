local leet_arg = 'leet'

if vim.g.enable_leetcode then
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
    },
  }
else
  return {}
end