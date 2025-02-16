local kind_icons = {
  Text = '',
  Method = '󰆧',
  Function = '󰊕',
  Constructor = '',
  Field = '󰇽',
  Variable = '󰂡',
  Class = '󰠱',
  Interface = '',
  Module = '',
  Property = '󰜢',
  Unit = '',
  Value = '󰎠',
  Enum = '',
  Keyword = '󰌋',
  Snippet = '',
  Color = '󰏘',
  File = '󰈙',
  Reference = '',
  Folder = '󰉋',
  EnumMember = '',
  Constant = '󰏿',
  Struct = '',
  Event = '',
  Operator = '󰆕',
  TypeParameter = '󰅲',
}

local cmp_tool = { -- Autocompletion
  nvim_cmp = {
    {
      'hrsh7th/nvim-cmp',
      event = 'BufRead',
      dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        {
          'L3MON4D3/LuaSnip',
          build = (function()
            -- Build Step is needed for regex support in snippets.
            -- This step is not supported in many windows environments.
            if vim.fn.executable 'make' == 0 then
              return
            end
            return 'make install_jsregexp'
          end)(),
          dependencies = {
            {
              'rafamadriz/friendly-snippets',
              config = function()
                require('luasnip.loaders.from_vscode').lazy_load()
              end,
            },
          },
        },
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
      },
      config = function()
        -- See `:help cmp`
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'

        luasnip.config.setup {}

        cmp.setup {
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          formatting = {
            fields = { 'abbr', 'kind', 'menu' },
            expandable_indicator = true,
            format = function(entry, vim_item)
              -- path source
              if vim.tbl_contains({ 'path' }, entry.source.name) then
                local icon, hl_group = require('nvim-web-devicons').get_icon(
                  entry.completion_item.label
                )
                if icon then
                  vim_item.kind = icon
                  vim_item.kind_hl_group = hl_group
                  return vim_item
                end
              end

              -- Kind icons
              -- concatenates the icons with the name of the item kind
              vim_item.abbr = vim_item.abbr .. ' '
              vim_item.kind = string.format(
                '%s %s',
                kind_icons[vim_item.kind],
                vim_item.kind
              ) .. ' '
              -- Source
              vim_item.menu = ({
                buffer = '(Buffer)',
                nvim_lsp = '(LSP)',
                luasnip = '(LuaSnip)',
                path = '(Path)',
                vimtex = '(TeX)',
                fuzzy_buffer = '(Fuzzy)',
              })[entry.source.name]
              vim_item.menu_hl_group = 'Comment'

              return vim_item
            end,
          },
          window = {
            completion = cmp.config.window.bordered {
              winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder,CursorLine:MyPmenuSel',
            },
            documentation = cmp.config.window.bordered {
              winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
            },
          },
          completion = { completeopt = 'menu,menuone,noinsert' },
          mapping = cmp.mapping.preset.insert {
            -- Select the [n]ext item
            ['<C-n>'] = cmp.mapping.select_next_item(),
            -- Select the [p]revious item
            ['<C-p>'] = cmp.mapping.select_prev_item(),

            -- Scroll the documentation window [b]ack / [f]orward
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),

            -- Accept the completion.
            ['<tab>'] = cmp.mapping.confirm { select = true },

            -- Abort the completion.
            ['<C-c>'] = cmp.mapping.abort(),

            -- Manually trigger a completion from nvim-cmp.
            ['<C-Space>'] = cmp.mapping.complete {},
          },
          sources = cmp.config.sources(
            {
              { name = 'nvim_lsp' },
              { name = 'luasnip' }, -- For luasnip users.
              { name = 'path' },
              {
                name = 'lazydev',
                group_index = 0, -- set group index to 0 to skip loading LuaLS completions
              },
              { name = 'buffer' },
            },
            -- if no item in the list, use the following sources
            {}
          ),
        }
        -- Use buffer source for `/` and `?`
        cmp.setup.cmdline({ '/', '?' }, {
          mapping = {
            ['<C-n>'] = { c = cmp.mapping.select_next_item() },
            ['<C-p>'] = { c = cmp.mapping.select_prev_item() },
            ['<tab>'] = { c = cmp.mapping.confirm { select = true } },
            ['<C-c>'] = { c = cmp.mapping.abort() },
          },
          sources = {
            { name = 'buffer' },
          },
        })
      end,
    },

    {
      'ray-x/lsp_signature.nvim',
      event = 'InsertEnter',
      opts = {
        hint_prefix = ' ',
        floating_window_off_x = 5, -- adjust float windows x position.
        floating_window_off_y = function() -- adjust float windows y position. e.g. set to -2 can make floating window move up 2 lines
          local pumheight = vim.o.pumheight
          local winline = vim.fn.winline() -- line number in the window
          local winheight = vim.fn.winheight(0)

          -- window top
          if winline - 1 < pumheight then
            return pumheight
          end

          -- window bottom
          if winheight - winline < pumheight then
            return -pumheight
          end
          return 0
        end,
      },
      config = function(_, opts)
        require('lsp_signature').setup(opts)
      end,
    },
  },

  blink_cmp = {
    {
      'saghen/blink.cmp',
      event = 'BufRead',
      version = '*',
      dependencies = {
        'rafamadriz/friendly-snippets',
        {
          'saghen/blink.compat',
          version = '*',
          -- make sure to set opts so that lazy.nvim calls blink.compat's setup
        },
      },
      -- use a release tag to download pre-built binaries
      config = function()
        local components =
          require('blink.cmp.config.completion.menu').default.draw.components
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        local opts = {
          appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = 'normal',
            kind_icons = kind_icons,
          },

          completion = {
            accept = { auto_brackets = { enabled = false } }, -- auto brackets
            menu = {
              auto_show = function(ctx)
                -- do not work in cmdline mode but search
                return ctx.mode ~= 'cmdline'
                  or vim.tbl_contains({ '/', '?' }, vim.fn.getcmdtype())
              end,
              border = 'rounded',
              draw = {
                -- like nvim-cmp
                columns = {
                  { 'label', 'label_description', gap = 1 },
                  { 'kind_icon', 'kind' },
                  { 'source_name' },
                },
                components = {
                  -- use the highlights from mini.icons
                  kind_icon = {
                    highlight = function(ctx)
                      local _, hl, _ =
                        require('mini.icons').get('lsp', ctx.kind)
                      return hl
                    end,
                  },
                  kind = {
                    highlight = function(ctx)
                      local _, hl, _ =
                        require('mini.icons').get('lsp', ctx.kind)
                      return hl
                    end,
                  },
                  -- add support for file icons
                  label = {
                    text = function(ctx)
                      if ctx.source_name == 'Path' then
                        local icon, _ =
                          require('mini.icons').get('file', ctx.label)
                        return icon .. ' ' .. ctx.label
                      end
                      ---@diagnostic disable-next-line: need-check-nil
                      return components.label.text(ctx)
                    end,
                    highlight = function(ctx)
                      if ctx.source_name == 'Path' then
                        local _, hl_group =
                          require('mini.icons').get('file', ctx.label)
                        return hl_group
                      end
                      ---@diagnostic disable-next-line: need-check-nil, missing-parameter
                      return components.label.highlight(ctx)
                    end,
                  },
                  -- same as nvim-cmp
                  source_name = {
                    text = function(ctx)
                      return '(' .. ctx.source_name .. ')'
                    end,
                  },
                },
                -- highlight item in the menu
                treesitter = { 'lsp' },
              },
            },
            documentation = {
              window = { border = 'rounded' },
              -- auto show documentation
              auto_show = true,
              auto_show_delay_ms = 300,
            },
            ghost_text = {
              enabled = false,
            },
          },
          keymap = {
            preset = 'default',
            ['<Tab>'] = {
              'select_and_accept',
              'fallback',
            },
          },

          signature = {
            enabled = true,
            window = { border = 'rounded' },
          },

          sources = {
            default = function()
              local success, node = pcall(vim.treesitter.get_node)
              if
                success
                and node
                and vim.tbl_contains(
                  { 'comment', 'line_comment', 'block_comment' },
                  node:type()
                )
              then
                -- sources used in comments
                return { 'path', 'buffer' }
              else
                if
                  vim.g.options.debug
                  and require('utils.util').find_value(
                    vim.bo.filetype,
                    { 'dap-repl', 'dapui_watches', 'dapui_hover' }
                  )
                then
                  return { 'dap', 'buffer' }
                end
                if vim.g.options.tex and vim.bo.filetype == 'tex' then
                  return { 'vimtex', 'path', 'snippets', 'buffer' }
                end
                return { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' }
              end
            end,
            providers = {
              lazydev = {
                name = 'LazyDev',
                module = 'lazydev.integrations.blink',
                -- make lazydev completions top priority (see `:h blink.cmp`)
                score_offset = 100,
              },
              dap = {
                name = 'dap',
                module = 'blink.compat.source',
                score_offset = 3,
              },
              vimtex = {
                name = 'vimtex',
                module = 'blink.compat.source',
                score_offset = 3,
              },
            },
          },

          cmdline = {
            enabled = true,
            keymap = {
              preset = 'default',
              ['<Tab>'] = {
                'show',
                'select_and_accept',
                'fallback',
              },
            },
            ---@diagnostic disable-next-line: assign-type-mismatch
            sources = function()
              local type = vim.fn.getcmdtype()
              -- Search forward and backward
              if type == '/' or type == '?' then
                return { 'buffer' }
              end
              -- Commands
              if type == ':' or type == '@' then
                return { 'path', 'cmdline' }
              end
              return {}
            end,
          },
        }

        -- required by nvim-cmp
        if vim.g.options.debug then
          opts.enabled = function()
            return vim.bo.buftype ~= 'prompt'
              or require('utils.util').find_value(
                vim.bo.filetype,
                { 'dap-repl', 'dapui_watches', 'dapui_hover' }
              )
          end
        end

        require('blink.cmp').setup(opts)
      end,
    },
  },
}
return {
  cmp_tool[vim.g.options.cmp],

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- Optional dependency
    config = function()
      require('nvim-autopairs').setup {}
      if vim.g.options.cmp == 'nvim_cmp' then
        -- If you want to automatically add `(` after selecting a function or method
        local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
        local cmp = require 'cmp'
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
      else
      end
    end,
  },
}
