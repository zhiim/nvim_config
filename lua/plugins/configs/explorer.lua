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
    enabled = vim.g.options.util,
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
    enabled = vim.g.options.util,
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
    'refractalize/oil-git-status.nvim',
    config = function()
      require('oil-git-status').setup {
        show_ignored = true,
        symbols = { -- customize the symbols that appear in the git status columns
          index = {
            ['!'] = ' ',
            ['?'] = ' ',
            ['A'] = 'A',
            ['C'] = 'C',
            ['D'] = 'D',
            ['M'] = 'M',
            ['R'] = 'R',
            ['T'] = 'T',
            ['U'] = 'U',
            [' '] = ' ',
          },
          working_tree = {
            ['!'] = '!',
            ['?'] = '?',
            ['A'] = ' ',
            ['C'] = 'C',
            ['D'] = 'D',
            ['M'] = 'M',
            ['R'] = 'R',
            ['T'] = 'T',
            ['U'] = 'U',
            [' '] = ' ',
          },
        },
      }
      vim.api.nvim_set_hl(0, 'OilGitStatusIndex', { link = 'NonText' })
      vim.api.nvim_set_hl(
        0,
        'OilGitStatusWorkingTreeIgnored',
        { link = 'NonText' }
      )
      vim.api.nvim_set_hl(
        0,
        'OilGitStatusWorkingTreeUntracked',
        { link = 'NeoTreeGitUntracked' }
      )
      vim.api.nvim_set_hl(
        0,
        'OilGitStatusWorkingTreeAdded',
        { link = 'NeoTreeGitAdded' }
      )
      vim.api.nvim_set_hl(
        0,
        'OilGitStatusWorkingTreeDeleted',
        { link = 'NeoTreeGitDeleted' }
      )
      vim.api.nvim_set_hl(
        0,
        'OilGitStatusWorkingTreeModified',
        { link = 'NeoTreeGitModified' }
      )
      vim.api.nvim_set_hl(
        0,
        'OilGitStatusWorkingTreeRenamed',
        { link = 'NeoTreeGitRenamed' }
      )
      vim.api.nvim_set_hl(
        0,
        'OilGitStatusWorkingTreeUnmerged',
        { link = 'NeoTreeGitConflict' }
      )
    end,
    dependencies = {
      'stevearc/oil.nvim',
      cmd = 'Oil',
      enabled = vim.fn.has 'nvim-0.8' and vim.g.options.util,
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
            signcolumn = 'yes:2',
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
  },

  {
    'echasnovski/mini.files',
    version = false,
    keys = {
      {
        '<leader>e',
        function()
          if not MiniFiles.close() then
            require('mini.files').open()
          end
        end,
        desc = 'Explorer mini.files',
        mode = 'n',
      },
    },
    config = function()
      -- use rounded border
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesWindowOpen',
        callback = function(args)
          local win_id = args.data.win_id

          -- Customize window-local settings
          local config = vim.api.nvim_win_get_config(win_id)
          config.border = 'rounded' -- set border to rounded
          vim.api.nvim_win_set_config(win_id, config)
        end,
      })

      -- Toggle dotfiles in MiniFiles
      local show_dotfiles = false
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
      end
      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        MiniFiles.refresh { content = { filter = new_filter } }
      end
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id
          -- Tweak left-hand side of mapping to your liking
          vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id })
        end,
      })

      require('mini.files').setup {}

      -- +---------------------------------------------------------+
      -- |                git status for mimi.files                |
      -- +---------------------------------------------------------+
      local nsMiniFiles = vim.api.nvim_create_namespace 'mini_files_git'
      local autocmd = vim.api.nvim_create_autocmd
      local _, MiniFiles = pcall(require, 'mini.files')

      -- Cache for git status
      local gitStatusCache = {}
      local cacheTimeout = 2000 -- in milliseconds
      local uv = vim.uv or vim.loop

      local function isSymlink(path)
        local stat = uv.fs_lstat(path)
        return stat and stat.type == 'link'
      end

      ---@type table<string, {symbol: string, hlGroup: string}>
      ---@param status string
      ---@return string symbol, string hlGroup
      local function mapSymbols(status, is_symlink)
        local statusMap = {
      -- stylua: ignore start 
      [" M"] = { symbol = "•", hlGroup  = "MiniDiffSignChange"}, -- Modified in the working directory
      ["M "] = { symbol = "✹", hlGroup  = "MiniDiffSignChange"}, -- modified in index
      ["MM"] = { symbol = "≠", hlGroup  = "MiniDiffSignChange"}, -- modified in both working tree and index
      ["A "] = { symbol = "+", hlGroup  = "MiniDiffSignAdd"   }, -- Added to the staging area, new file
      ["AA"] = { symbol = "≈", hlGroup  = "MiniDiffSignAdd"   }, -- file is added in both working tree and index
      ["D "] = { symbol = "-", hlGroup  = "MiniDiffSignDelete"}, -- Deleted from the staging area
      ["AM"] = { symbol = "⊕", hlGroup  = "MiniDiffSignChange"}, -- added in working tree, modified in index
      ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange"}, -- Added in the index and deleted in the working directory
      ["R "] = { symbol = "→", hlGroup  = "MiniDiffSignChange"}, -- Renamed in the index
      ["U "] = { symbol = "‖", hlGroup  = "MiniDiffSignChange"}, -- Unmerged path
      ["UU"] = { symbol = "⇄", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged
      ["UA"] = { symbol = "⊕", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged and added in working tree
      ["??"] = { symbol = "?", hlGroup  = "NeoTreeGitUntracked"}, -- Untracked files
      ["!!"] = { symbol = "!", hlGroup  = "NonText"}, -- Ignored files
          -- stylua: ignore end
        }

        local result = statusMap[status]
          or { symbol = '?', hlGroup = 'NonText' }
        local gitSymbol = result.symbol
        local gitHlGroup = result.hlGroup

        local symlinkSymbol = is_symlink and '↩' or ''

        -- Combine symlink symbol with Git status if both exist
        local combinedSymbol = (symlinkSymbol .. gitSymbol)
          :gsub('^%s+', '')
          :gsub('%s+$', '')
        -- Change the color of the symlink icon from "MiniDiffSignDelete" to something else
        local combinedHlGroup = is_symlink and 'MiniDiffSignDelete'
          or gitHlGroup

        return combinedSymbol, combinedHlGroup
      end

      ---@param cwd string
      ---@param callback function
      ---@return nil
      local function fetchGitStatus(cwd, callback)
        local clean_cwd = cwd:gsub('^minifiles://%d+/', '')
        ---@param content table
        local function on_exit(content)
          if content.code == 0 then
            callback(content.stdout)
            -- vim.g.content = content.stdout
          end
        end
        ---@see vim.system
        vim.system(
          { 'git', 'status', '--ignored', '--porcelain' },
          { text = true, cwd = clean_cwd },
          on_exit
        )
      end

      ---@param buf_id integer
      ---@param gitStatusMap table
      ---@return nil
      local function updateMiniWithGit(buf_id, gitStatusMap)
        vim.schedule(function()
          local nlines = vim.api.nvim_buf_line_count(buf_id)
          local cwd = vim.fs.root(buf_id, '.git')
          local escapedcwd = cwd and vim.pesc(cwd)
          escapedcwd = vim.fs.normalize(escapedcwd)

          for i = 1, nlines do
            local entry = MiniFiles.get_fs_entry(buf_id, i)
            if not entry then
              break
            end
            local relativePath = entry.path:gsub('^' .. escapedcwd .. '/', '')
            local status = gitStatusMap[relativePath]

            if status then
              local symbol, hlGroup = mapSymbols(status, isSymlink(entry.path))
              vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
                sign_text = symbol,
                sign_hl_group = hlGroup,
                priority = 2,
              })
              -- This below code is responsible for coloring the text of the items. comment it out if you don't want that
              local line =
                vim.api.nvim_buf_get_lines(buf_id, i - 1, i, false)[1]
              -- Find the name position accounting for potential icons
              local nameStartCol = line:find(vim.pesc(entry.name)) or 0

              if nameStartCol > 0 then
                vim.api.nvim_buf_set_extmark(
                  buf_id,
                  nsMiniFiles,
                  i - 1,
                  nameStartCol - 1,
                  {
                    end_col = nameStartCol + #entry.name - 1,
                    hl_group = hlGroup,
                  }
                )
              end
            else
            end
          end
        end)
      end

      -- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
      ---@param content string
      ---@return table
      local function parseGitStatus(content)
        local gitStatusMap = {}
        -- lua match is faster than vim.split (in my experience )
        for line in content:gmatch '[^\r\n]+' do
          local status, filePath = string.match(line, '^(..)%s+(.*)')
          -- Split the file path into parts
          local parts = {}
          for part in filePath:gmatch '[^/]+' do
            table.insert(parts, part)
          end
          -- Start with the root directory
          local currentKey = ''
          for i, part in ipairs(parts) do
            if i > 1 then
              -- Concatenate parts with a separator to create a unique key
              currentKey = currentKey .. '/' .. part
            else
              currentKey = part
            end
            -- If it's the last part, it's a file, so add it with its status
            if i == #parts then
              gitStatusMap[currentKey] = status
            else
              -- If it's not the last part, it's a directory. Check if it exists, if not, add it.
              if not gitStatusMap[currentKey] then
                gitStatusMap[currentKey] = status
              end
            end
          end
        end
        return gitStatusMap
      end

      ---@param buf_id integer
      ---@return nil
      local function updateGitStatus(buf_id)
        if not vim.fs.root(buf_id, '.git') then
          return
        end
        local cwd = vim.fs.root(buf_id, '.git')
        -- local cwd = vim.fn.expand("%:p:h")
        local currentTime = os.time()

        if
          gitStatusCache[cwd]
          and currentTime - gitStatusCache[cwd].time < cacheTimeout
        then
          updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
        else
          fetchGitStatus(cwd, function(content)
            local gitStatusMap = parseGitStatus(content)
            gitStatusCache[cwd] = {
              time = currentTime,
              statusMap = gitStatusMap,
            }
            updateMiniWithGit(buf_id, gitStatusMap)
          end)
        end
      end

      ---@return nil
      local function clearCache()
        gitStatusCache = {}
      end

      local function augroup(name)
        return vim.api.nvim_create_augroup(
          'MiniFiles_' .. name,
          { clear = true }
        )
      end

      autocmd('User', {
        group = augroup 'start',
        pattern = 'MiniFilesExplorerOpen',
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          updateGitStatus(bufnr)
        end,
      })

      autocmd('User', {
        group = augroup 'close',
        pattern = 'MiniFilesExplorerClose',
        callback = function()
          clearCache()
        end,
      })

      autocmd('User', {
        group = augroup 'update',
        pattern = 'MiniFilesBufferUpdate',
        callback = function(args)
          local bufnr = args.data.buf_id
          local cwd = vim.fs.root(bufnr, '.git')
          if gitStatusCache[cwd] then
            updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
          end
        end,
      })
    end,
  },
}
