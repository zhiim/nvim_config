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
  },

  blink_cmp = {
    {
      'saghen/blink.cmp',
      event = 'BufRead',
      version = '*',
      dependencies = 'rafamadriz/friendly-snippets',
      -- use a release tag to download pre-built binaries
      config = function()
        vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { link = 'NormalFloat' })
        vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { link = 'FloatBorder' })
        vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', { link = 'MyPmenuSel' })
        vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { link = 'FloatBorder' })

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
              function(cmp)
                if cmp.snippet_active() then
                  return cmp.accept()
                else
                  return cmp.select_and_accept()
                end
              end,
              'snippet_forward',
              'fallback',
            },
          },

          signature = {
            enabled = false,
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
            },
          },
        }
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
    dependencies = { 'hrsh7th/nvim-cmp' },
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

  -- {
  --   'xzbdmw/colorful-menu.nvim',
  --   config = function()
  --     require('colorful-menu').setup {
  --       ls = {
  --         -- If true, try to highlight "not supported" languages.
  --         fallback = true,
  --       },
  --       -- If the built-in logic fails to find a suitable highlight group,
  --       -- this highlight is applied to the label.
  --       fallback_highlight = '@variable',
  --       -- If provided, the plugin truncates the final displayed text to
  --       -- this width (measured in display cells). Any highlights that extend
  --       -- beyond the truncation point are ignored. Default 60.
  --       max_width = 60,
  --     }
  --   end,
  -- },
}
