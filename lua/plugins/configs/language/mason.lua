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

    local reverse_mason_name = {
      -- lsp
      ['cmake-language-server'] = 'cmake',
      ['lua-language-server'] = 'lua_ls',
      -- formatters
      ['cmakelang'] = 'cmake_format',
    }
    local language_basic_opts = language_opts.components.basic

    local server_opts = language_basic_opts.lsp_server
    if not server_opts.use_all then
      ensure_installed = vim.tbl_filter(function(sv)
        local sv_status = server_opts.servers[reverse_mason_name[sv] or sv]
        return sv_status == nil or sv_status
      end, ensure_installed)
    end

    local formatter_opts = language_basic_opts.formatter
    if not formatter_opts.use_all then
      ensure_installed = vim.tbl_filter(function(fmt)
        local fmt_status =
          formatter_opts.formatters[reverse_mason_name[fmt] or fmt]
        return fmt_status == nil or fmt_status
      end, ensure_installed)
    end

    local linter_opts = language_basic_opts.linter
    if not linter_opts.use_all then
      ensure_installed = vim.tbl_filter(function(lt)
        local lt_status = linter_opts.linters[reverse_mason_name[lt] or lt]
        return lt_status == nil or lt_status
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
