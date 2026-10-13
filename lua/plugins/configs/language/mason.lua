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
    local ensure_installed = {}
    local mason_names = {
      -- lsp
      neocmake = 'neocmakelsp',
      lua_ls = 'lua-language-server',
      -- formatters
      cmake_format = 'cmakelang',
    }
    local language_basic_opts = language_opts.components.basic

    local function add_tools(opts, tools)
      for name, enabled in pairs(tools) do
        -- gofmt is provided by Go, not Mason.
        if (opts.use_all or enabled) and name ~= 'gofmt' then
          local package_name = mason_names[name] or name
          if not vim.tbl_contains(ensure_installed, package_name) then
            table.insert(ensure_installed, package_name)
          end
        end
      end
    end

    local server_opts = language_basic_opts.lsp_server
    local formatter_opts = language_basic_opts.formatter
    local linter_opts = language_basic_opts.linter
    add_tools(server_opts, server_opts.servers)
    add_tools(formatter_opts, formatter_opts.formatters)
    add_tools(linter_opts, linter_opts.linters)

    -- enable texlab
    if vim.g.options.plugins.tex then
      ensure_installed =
        vim.list_extend(ensure_installed, { 'texlab', 'latexindent' })
    end

    -- auto download
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
  end,
}
