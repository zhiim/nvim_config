local conda_command = "fd '^python.exe$' D:\\condaEnvs -t x -t l"
local venv_command = "fd '^python.exe$' D:\\venv -t x -t l"
-- local conda_command = "fd '^python$' /home/xu/miniconda3/envs -t x -t l"
-- local venv_command = "fd '^python$' /home/xu/.venvtool -t x -t l"

return {
  'linux-cultist/venv-selector.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
  },
  lazy = false,
  branch = 'regexp', -- This is the regexp branch, use this for the new version
  config = function()
    require('venv-selector').setup {
      settings = {
        search = {
          find_conda = {
            command = conda_command,
          },
          find_venv = {
            command = venv_command,
          },
        },
      },
    }
  end,
  keys = {
    { '<leader>vs', '<cmd>VenvSelect<cr>' },
  },
}
