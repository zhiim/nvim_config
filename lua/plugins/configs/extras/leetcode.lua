local leet_arg = 'leetcode'

return {
  'kawre/leetcode.nvim',
  lazy = leet_arg ~= vim.fn.argv()[1], -- lazy load
  cmd = 'Leet',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim', -- required by telescope
    'MunifTanjim/nui.nvim',
    '3rd/image.nvim',
  },
  enabled = vim.g.options.leetcode,
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
    image_support = true,
    config = function()
      vim.cmd 'TSUpdate html'
    end,
  },
}
