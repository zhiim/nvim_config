local leet_arg = 'leetcode'

return {
  'kawre/leetcode.nvim',
  lazy = leet_arg ~= vim.fn.argv()[1], -- lazy load
  cmd = 'Leet',
  dependencies = {
    'MunifTanjim/nui.nvim',
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
    image_support = vim.fn.has 'linux' and vim.fn.has 'wsl' == 0,
    config = function()
      vim.cmd 'TSUpdate html'
    end,
  },
}
