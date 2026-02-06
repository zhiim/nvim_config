local language_opts = vim.g.options.plugins.language

return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  enabled = (
    language_opts.components.basic.enabled or language_opts.enable_all
  ),
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

    local to_mason_name = {
      -- lsp
      [' cmake'] = 'cmake-language-server',
      ['lua_ls'] = 'lua-language-server',
      -- formatters
      ['cmake_format'] = 'cmakelang',
    }
    local language_basic_opts = language_opts.components.basic

    local server_opts = language_basic_opts.lsp_server
    if not server_opts.use_all then
      ensure_installed = vim.tbl_filter(function(sv)
        return server_opts.servers[to_mason_name[sv] or sv]
      end, ensure_installed)
    end

    local formatter_opts = language_basic_opts.formatter
    if not formatter_opts.use_all then
      ensure_installed = vim.tbl_filter(function(fmt)
        return formatter_opts.formatters[to_mason_name[fmt] or fmt]
      end, ensure_installed)
    end

    local linter_opts = language_basic_opts.linter
    if not linter_opts.use_all then
      ensure_installed = vim.tbl_filter(function(lt)
        return linter_opts.linters[to_mason_name[lt] or lt]
      end, ensure_installed)
    end

    -- enable texlab
    if vim.g.options.plugins.tex then
      ensure_installed =
        vim.list_extend(ensure_installed, { 'texlab', 'latexindent' })
    end
    -- auto download
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
  end,
}
