return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
  },
  config = function()
    local ensure_installed = {
      -- lsp servers
      'clangd',
      'taplo',
      'cmake-language-server',
      'basedpyright',
      'ruff',
      'lua-language-server',
      -- formatters
      'stylua',
      'clang-format',
      'cmakelang',
      'prettier',
      'taplo',
      -- linters
      'jsonlint',
      'yamllint',
    }
    -- enable texlab
    if vim.g.options.tex then
      ensure_installed =
        vim.list_extend(ensure_installed, { 'texlab', 'latexindent' })
    end
    -- auto download
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
  end,
}
