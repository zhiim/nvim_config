return {
  'Bekaboo/dropbar.nvim',
  event = 'BufReadPre',
  enabled = vim.g.options.enhance,
  keys = {
    {
      '<leader>db',
      function()
        require('dropbar.api').pick()
      end,
      mode = 'n',
      desc = 'Dropbar pick',
    },
  },
  config = function()
    -- hightlight current file name
    local custom_path = {
      get_symbols = function(buff, win, cursor)
        local symbols =
          require('dropbar.sources').path.get_symbols(buff, win, cursor)
        vim.api.nvim_set_hl(
          0,
          'DropBarFileName',
          { italic = true, bold = true }
        )
        symbols[#symbols].name_hl = 'DropBarFileName'
        return symbols
      end,
    }

    local function custom_fallback(sources)
      local function get_lsp(buf)
        local clients = vim.lsp.get_clients { bufnr = buf }
        if vim.tbl_isempty(clients) then
          return false
        end
        return true
      end
      return {
        get_symbols = function(buf, win, cursor)
          local symbols
          if get_lsp(buf) then -- use lsp
            symbols = sources[1].get_symbols(buf, win, cursor)
          else -- fallback to treesitter
            symbols = sources[2].get_symbols(buf, win, cursor)
          end
          if not vim.tbl_isempty(symbols) then
            return symbols
          end
          return {}
        end,
      }
    end
    local utils = require 'dropbar.utils'
    require('dropbar').setup {
      bar = {
        -- when to attach the bar
        enable = function(buf, win, _)
          return vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_win_is_valid(win)
            and vim.wo[win].winbar == ''
            and vim.fn.win_gettype(win) == ''
            -- do not attach to certain filetypes
            and not require('utils.util').find_value(
              vim.bo[buf].ft,
              { 'help', 'copilot-chat', 'codecompanion' }
            )
            and ((pcall(vim.treesitter.get_parser, buf)) and true or false)
        end,
        sources = function(buf, _)
          local sources = require 'dropbar.sources'
          if vim.bo[buf].ft == 'markdown' then
            return {
              custom_path,
              sources.markdown,
            }
          end
          if vim.bo[buf].buftype == 'terminal' then
            return {
              sources.terminal,
            }
          end
          return {
            custom_path,
            custom_fallback {
              sources.lsp,
              sources.treesitter,
            },
          }
        end,
      },
      menu = {
        keymaps = {
          -- close
          ['<Esc>'] = function()
            utils.menu.exec 'close'
          end,
          ['q'] = function()
            utils.menu.exec 'close'
          end,
          -- go to upper menu
          ['h'] = function()
            local menu = utils.menu.get_current()
            if not menu then
              return
            end
            if menu.prev_menu then
              menu:close()
            else
              local bar =
                require('dropbar.utils.bar').get { win = menu.prev_win }
              if bar ~= nil then
                local barComponents = bar.components[1]._.bar.components
                for _, component in ipairs(barComponents) do
                  if component.menu then
                    local idx = component._.bar_idx
                    menu:close()
                    require('dropbar.api').pick(idx - 1)
                  end
                end
              end
            end
          end,
          -- go to deeper menu
          ['l'] = function()
            local menu = utils.menu.get_current()
            if not menu then
              return
            end
            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
            if component then
              menu:click_on(component, nil, 1, 'l')
            end
          end,
          -- move to the selected item
          ['<CR>'] = function()
            local menu = utils.menu.get_current()
            if not menu then
              return
            end

            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            local entry = menu.entries[cursor[1]]
            -- stolen from https://github.com/Bekaboo/dropbar.nvim/issues/66
            local component = entry:first_clickable(
              entry.padding.left + entry.components[1]:bytewidth()
            )
            if component then
              menu:click_on(component, nil, 1, 'l')
            end
          end,
          -- fuzzy find
          ['i'] = function()
            local menu = utils.menu.get_current()
            if not menu then
              return
            end
            menu:fuzzy_find_open()
          end,
        },
        win_configs = {
          -- menu window border
          border = 'rounded',
          style = 'minimal',
        },
      },
    }
  end,
}
