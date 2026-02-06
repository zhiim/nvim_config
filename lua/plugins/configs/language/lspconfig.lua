local language_opts = vim.g.options.plugins.language

return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  enabled = vim.fn.argv()[1] ~= 'leetcode'
    and (language_opts.components.basic.enabled or language_opts.enable_all),
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

        if vim.g.options.picker.chosen == 2 then
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
            '<leader>ld',
            require('telescope.builtin').lsp_document_symbols,
            'LSP document symbols'
          )

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map(
            '<leader>lw',
            require('telescope.builtin').lsp_dynamic_workspace_symbols,
            'LSP workspace symbols'
          )
        else
          map(
            'gd',
            '<cmd>FzfLua lsp_definitions ignore_current_line=true<CR>',
            'LSP goto definition'
          )
          map(
            'gr',
            '<cmd>FzfLua lsp_references ignore_current_line=true<CR>',
            'LSP goto references'
          )
          map(
            'gI',
            '<cmd>FzfLua lsp_implementations ignore_current_line=true<CR>',
            'LSP goto implementation'
          )
          map(
            '<leader>D',
            '<cmd>FzfLua lsp_typedefs ignore_current_line=true<CR>',
            'LSP type definition'
          )
          map(
            '<leader>ld',
            '<cmd>FzfLua lsp_document_symbols<CR>',
            'LSP document symbols'
          )
          map(
            '<leader>lw',
            '<cmd>FzfLua lsp_live_workspace_symbols<CR>',
            'LSP workspace symbols'
          )
        end

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>lc', vim.lsp.buf.code_action, 'LSP code action')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, 'LSP goto Declaration')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
          client
          and client:supports_method(
            vim.lsp.protocol.Methods.textDocument_documentHighlight,
            event.buf
          )
        then
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
          and client:supports_method(
            vim.lsp.protocol.Methods.textDocument_inlayHint,
            event.buf
          )
        then
          map('<leader>lh', function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
            )
          end, 'LSP toggle inlay hints')
        end
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if vim.g.options.plugins.language.components.basic.cmp.chosen == 2 then
      capabilities = vim.tbl_deep_extend(
        'force',
        capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )
    end
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    vim.lsp.config('*', {
      capabilities = capabilities,
    })

    local server_opts = language_opts.components.basic.lsp_server

    if server_opts.use_all or server_opts.servers['clangd'] then
      vim.lsp.config('clangd', {
        cmd = { 'clangd', '--clang-tidy' },
      })
    end
    if server_opts.use_all or server_opts.servers['basedpyright'] then
      vim.lsp.config('basedpyright', {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = 'off', -- off, basic, standard, strict, all
              autoImportCompletions = false,
              autoSearchPaths = true,
              diagnosticMode = 'openFilesOnly',
              useLibraryCodeForTypes = true,
              reportMissingTypeStubs = false,
            },
          },
        },
      })
    end
    if server_opts.use_all or server_opts.servers['lua_ls'] then
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      })
    end

    -- use lspconfig name
    local servers = {
      'clangd',
      'taplo',
      'cmake',
      'basedpyright',
      'ruff',
      'lua_ls',
    }
    if not server_opts.use_all then
      servers = vim.tbl_filter(function(server)
        return server_opts.servers[server]
      end, servers)
    end

    if vim.g.options.plugins.tex then
      servers = vim.list_extend(servers, { 'texlab' })
    end
    vim.lsp.enable(servers)

    if server_opts.use_all or server_opts.servers['ruff'] then
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup(
          'lsp_attach_disable_ruff_hover',
          { clear = true }
        ),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client == nil then
            return
          end
          if client.name == 'ruff' then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end
        end,
        desc = 'LSP: Disable hover capability from Ruff',
      })
    end
  end,
}
