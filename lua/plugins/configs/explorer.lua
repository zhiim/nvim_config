local neotree_source_type = { 'filesystem', 'buffers', 'git_status' }
local neotree_source_idx = 1 -- 1: filesystem, 2: buffers, 3: git_status

--- Change NeoTree source type
local change_neotree_source = function(op)
  neotree_source_idx = neotree_source_idx + op
  if neotree_source_idx == 4 then
    neotree_source_idx = 1 -- back to filesystem
  end
  if neotree_source_idx == 0 then
    neotree_source_idx = 3 -- jumpu to git_status
  end
end

local file_explorers = {
  nvimtree = {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
    opts = {
      filters = {
        dotfiles = false,
      },
      disable_netrw = true,
      hijack_netrw = false,
      hijack_cursor = true,
      hijack_unnamed_buffer_when_opening = false,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        adaptive_size = false,
        side = 'left',
        width = 30,
        preserve_window_proportions = true,
      },
      git = {
        enable = true,
        ignore = true,
      },
      filesystem_watchers = {
        enable = true,
      },
      actions = {
        open_file = {
          resize_window = true,
        },
      },
      renderer = {
        root_folder_label = false,
        highlight_git = true,
        highlight_opened_files = 'none',

        indent_markers = {
          enable = true,
        },

        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },

          glyphs = {
            default = '󰈚',
            symlink = '󱅷',
            folder = {
              default = '󰉋',
              empty = '󰉋',
              empty_open = '󰜌',
              open = '󰝰',
              symlink = '',
              symlink_open = '',
              arrow_open = '',
              arrow_closed = '',
            },
            git = {
              unstaged = '',
              staged = '',
              unmerged = '󰽜',
              renamed = '󰁕',
              untracked = '',
              deleted = '',
              ignored = '',
            },
          },
        },
      },
    },
    keys = {
      {
        mode = 'n',
        '<C-n>',
        '<cmd>NvimTreeToggle<CR>',
        desc = 'Explorer sidebar',
      },
    },
    config = function(_, opts)
      require('nvim-tree').setup(opts)
    end,
  },

  neotree = {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      {
        '<C-n>',
        function()
          local ntc = require 'neo-tree.command'
          -- toggle with current source type
          if neotree_source_idx == 1 then
            ntc.execute { toggle = true, dir = vim.uv.cwd() }
          elseif neotree_source_idx == 2 then
            ntc.execute { source = 'buffers', toggle = true }
          elseif neotree_source_idx == 3 then
            ntc.execute { source = 'git_status', toggle = true }
          else
            vim.notify(
              'Unknown source type',
              vim.log.levels.WARN,
              { title = 'NeoTree' }
            )
          end
        end,
        desc = 'Explorer sidebar',
        mode = 'n',
      },
    },
    deactivate = function()
      vim.cmd [[Neotree close]]
    end,
    init = function()
      -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
      -- because `cwd` is not set up properly.
      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup(
          'Neotree_start_directory',
          { clear = true }
        ),
        desc = 'Start Neo-tree with directory',
        once = true,
        callback = function()
          if package.loaded['neo-tree'] then
            return
          else
            local stats = (vim.uv or vim.loop).fs_stat(vim.fn.argv(0))
            if stats and stats.type == 'directory' then
              require 'neo-tree'
            end
          end
        end,
      })
    end,
    opts = {
      sources = { 'filesystem', 'buffers', 'git_status' },
      open_files_do_not_replace_types = {
        'terminal',
        'Trouble',
        'trouble',
        'qf',
        'Outline',
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false, -- show hidden files
        },
        hijack_netrw_behavior = 'disabled',
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        -- width = 30, -- keep value with nvim-tree
        mappings = {
          ['l'] = 'open',
          ['h'] = 'close_node',
          ['<space>'] = 'none',
          ['Y'] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg('+', path, 'c')
            end,
            desc = 'Copy Path to Clipboard',
          },
          ['O'] = {
            function(state)
              require('lazy.util').open(
                state.tree:get_node().path,
                { system = true }
              )
            end,
            desc = 'Open with System Application',
          },
          ['P'] = { 'toggle_preview', config = { use_float = false } },
          [']'] = {
            function()
              change_neotree_source(1)
              vim.cmd(
                'Neotree focus '
                  .. neotree_source_type[neotree_source_idx]
                  .. ' left',
                true
              )
            end,
            desc = 'Focus Next Tab',
          },
          ['['] = {
            function()
              change_neotree_source(-1)
              vim.cmd(
                'Neotree focus '
                  .. neotree_source_type[neotree_source_idx]
                  .. ' left',
                true
              )
            end,
            desc = 'Focus Previous Tab',
          },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = '',
          expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
        icon = {
          folder_closed = '󰉋',
          folder_open = '󰝰',
          folder_empty = '󰜌',
        },
        modified = {
          symbol = '[+]',
          highlight = 'NeoTreeModified',
        },
        git_status = {
          symbols = {
            -- Change type
            added = '', -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified = '', -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = '', -- this can only be used in the git_status source
            renamed = '󰁕', -- this can only be used in the git_status source
            -- Status type
            untracked = '',
            ignored = '',
            unstaged = '',
            staged = '',
            conflict = '󰘬',
          },
        },
      },
      source_selector = { -- show source selector on the top as clickable tabs
        winbar = true,
        statusline = false,
      },
    },
    config = function(_, opts)
      opts.event_handlers = opts.event_handlers or {}
      require('neo-tree').setup(opts)
      -- refresh git status after closing lazygit
      vim.api.nvim_create_autocmd('TermClose', {
        pattern = '*lazygit',
        callback = function()
          if package.loaded['neo-tree.sources.git_status'] then
            require('neo-tree.sources.git_status').refresh()
          end
        end,
      })
    end,
  },
}

local detail = false

return {
  file_explorers[vim.g.options.explorer],

  {
    'stevearc/oil.nvim',
    cmd = 'Oil',
    enabled = vim.fn.has 'nvim-0.8',
    keys = {
      {
        '<C-p>',
        function()
          local path = vim.fn.getcwd()
          vim.cmd('Oil ' .. path)
        end,
        desc = 'Explorer netrw',
        mode = 'n',
      },
      {
        '<A-p>',
        '<cmd>Oil<CR>',
        desc = 'Explorer netrw in parent directory',
        mode = 'n',
      },
    },
    config = function()
      function _G.get_oil_winbar()
        local dir = require('oil').get_current_dir()
        if dir then
          return vim.fn.fnamemodify(dir, ':~')
        else
          -- If there is no current directory (e.g. over ssh), just show the buffer name
          return vim.api.nvim_buf_get_name(0)
        end
      end

      require('oil').setup {
        columns = {
          'icon',
        },
        delete_to_trash = true,
        view_options = {
          -- Show files and directories that start with "."
          show_hidden = false,
        },
        win_options = {
          wrap = true,
          winbar = '%!v:lua.get_oil_winbar()',
        },
        keymaps = {
          ['g?'] = { 'actions.show_help', mode = 'n' },
          ['<CR>'] = 'actions.select',
          ['<A-r>'] = 'actions.refresh',
          ['P'] = 'actions.preview',
          ['q'] = { 'actions.close', mode = 'n' },
          ['-'] = { 'actions.parent', mode = 'n' },
          ['_'] = { 'actions.open_cwd', mode = 'n' },
          ['`'] = { 'actions.cd', mode = 'n' },
          ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
          ['gs'] = { 'actions.change_sort', mode = 'n' },
          ['gx'] = 'actions.open_external',
          ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
          ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
          ['gd'] = {
            desc = 'Toggle file detail view',
            callback = function()
              detail = not detail
              if detail then
                require('oil').set_columns {
                  'icon',
                  'permissions',
                  'size',
                  'mtime',
                }
              else
                require('oil').set_columns { 'icon' }
              end
            end,
          },
        },
        use_default_keymaps = false,
      }
    end,
  },
}
