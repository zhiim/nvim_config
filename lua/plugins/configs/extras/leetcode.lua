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
      home = vim.fn.getcwd(),
    },
    hooks = {
      ['enter'] = function()
        if vim.g.options.ai then
          vim.cmd 'Copilot disable'
        end
      end,
      ['leave'] = function()
        if vim.g.options.ai then
          vim.cmd 'Copilot enable'
        end
      end,
    },
    image_support = true,
    config = function()
      vim.cmd 'TSUpdate html'
    end,
  },
}
