if not vim.g.enable_language_support then
  return {}
end
return {
  'linux-cultist/venv-selector.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
  },
  event = 'BufEnter *.py', -- lazy load when entering python files
  branch = 'regexp', -- This is the regexp branch, use this for the new version
  config = function()
    require('venv-selector').setup {
      settings = {
        search = {
          find_conda = {
            command = vim.g.python_conda_command,
          },
          find_venv = {
            command = vim.g.python_venv_command,
          },
        },
      },
    }
  end,
  keys = {
    { '<leader>vs', '<cmd>VenvSelect<cr>' },
  },
}
