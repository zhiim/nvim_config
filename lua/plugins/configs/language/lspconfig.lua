return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true }, -- Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup(
        'kickstart-lsp-attach',
        { clear = true }
      ),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
        end

        -- Jump to the definition of the word under your cursor.
        map(
          'gd',
          require('telescope.builtin').lsp_definitions,
          'LSP goto definition'
        )

        -- Find references for the word under your cursor.
        map(
          'gr',
          require('telescope.builtin').lsp_references,
          'LSP goto references'
        )

        -- Jump to the implementation of the word under your cursor.
        map(
          'gI',
          require('telescope.builtin').lsp_implementations,
          'LSP goto implementation'
        )

        -- Jump to the type of the word under your cursor.
        map(
          '<leader>D',
          require('telescope.builtin').lsp_type_definitions,
          'LSP type definition'
        )

        -- Fuzzy find all the symbols in your current document.
        map(
          '<leader>ds',
          require('telescope.builtin').lsp_document_symbols,
          'LSP document symbols'
        )

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map(
          '<leader>ws',
          require('telescope.builtin').lsp_dynamic_workspace_symbols,
          'LSP workspace symbols'
        )

        -- Rename the variable under your cursor.
        -- use inc_rename
        -- map('<leader>rn', vim.lsp.buf.rename, 'LSP rename')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, 'LSP code action')

        -- Opens a popup that displays documentation about the word under your cursor
        map('K', vim.lsp.buf.hover, 'LSP hover documentation')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, 'LSP goto Declaration')

        vim.keymap.set(
          'n',
          '<leader>lsp',
          '<CMD>LspStop<CR>',
          { desc = 'LSP stop LSP server' }
        )
        vim.keymap.set(
          'n',
          '<leader>lst',
          '<CMD>LspStart<CR>',
          { desc = 'LSP start LSP server' }
        )

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup(
            'kickstart-lsp-highlight',
            { clear = false }
          )
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup(
              'kickstart-lsp-detach',
              { clear = true }
            ),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds {
                group = 'kickstart-lsp-highlight',
                buffer = event2.buf,
              }
            end,
          })
        end

        -- The following autocommand is used to enable inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if
          client
          and client.server_capabilities.inlayHintProvider
          and vim.lsp.inlay_hint
        then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, 'LSP toggle inlay hints')
        end
      end,
    })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend(
      'force',
      capabilities,
      require('cmp_nvim_lsp').default_capabilities()
    )
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    -- NOTE: add lsp need to be configured with lspconfig here
    local servers = {
      clangd = {},

      taplo = {},

      cmake = {},

      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = 'basic', -- off, basic, standard, strict, all
              autoImportCompletions = false,
              autoSearchPaths = true,
              diagnosticMode = 'openFilesOnly',
              useLibraryCodeForTypes = true,
              reportMissingTypeStubs = false,
            },
          },
        },
      },

      ruff = {}, -- incase ruff lsp attached to other file type

      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
    }

    -- enable texlab
    if vim.g.options.tex then
      servers.texlab = {}
    end

    require('mason').setup()

    local ensure_installed = vim.tbl_keys(servers or {})

    -- NOTE: add packages need to be installed with Mason here,
    --       lsp added in `servers` is already included
    vim.list_extend(ensure_installed, {
      -- lua
      'stylua',

      -- c/cpp stuff
      'clang-format',
      -- "codelldb",  -- c/c++ debugger
      'cmake-language-server',
      'cmakelang', -- cmake formatter

      -- python stuff
      'ruff', -- linter with lots of syntex check
      -- "debugpy", -- used with dap-python

      -- markdown
      'prettier',

      -- json
      'jsonlint',

      -- yaml
      'yamllint',
    })
    -- latex formatter
    if vim.g.options.tex then
      vim.list_extend(ensure_installed, {
        'latexindent',
      })
    end

    -- auto download
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          -- This handles overriding only values explicitly passed
          -- by the server configuration above. Useful when disabling
          -- certain features of an LSP (for example, turning off formatting for tsserver)
          server.capabilities = vim.tbl_deep_extend(
            'force',
            {},
            capabilities,
            server.capabilities or {}
          )
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }

    -- NOTE: add custom configuration for lsp here
    require('lspconfig').clangd.setup {
      cmd = { 'clangd', '--clang-tidy' },
    }
  end,
}
