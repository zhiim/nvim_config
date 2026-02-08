-- Nvim Settings TUI using nui.nvim
-- Manages opts_cache.json configuration
local M = {}

local utils = require 'utils.util'

-- Deep copy a table
local function deep_copy(orig)
  local copy
  if type(orig) == 'table' then
    copy = {}
    for k, v in pairs(orig) do
      copy[k] = deep_copy(v)
    end
  else
    copy = orig
  end
  return copy
end

-- Helper function to get nested value from table by path
local function get_nested(tbl, path)
  local current = tbl
  for key in string.gmatch(path, '[^.]+') do
    if type(current) ~= 'table' then
      return nil
    end
    current = current[key]
  end
  return current
end

-- Helper function to set nested value in table by path
local function set_nested(tbl, path, value)
  local keys = {}
  for key in string.gmatch(path, '[^.]+') do
    table.insert(keys, key)
  end

  local current = tbl
  for i = 1, #keys - 1 do
    if type(current[keys[i]]) ~= 'table' then
      current[keys[i]] = {}
    end
    current = current[keys[i]]
  end
  current[keys[#keys]] = value
end

-- Current working copy of options
local working_options = nil

-- Tab definitions
local tabs = {
  { id = 'general', label = 'General' },
  { id = 'theme', label = 'Theme' },
  { id = 'plugin', label = 'Plugins' },
  { id = 'lsp', label = 'LSP' },
}

local current_tab_idx = 1

-- Build menu items for a tab
local function build_menu_lines(tab_id)
  local Menu = require 'nui.menu'
  local NuiText = require 'nui.text'
  local items = {}
  local opts = working_options

  local enabled_icon = function(v)
    return v and '' or ''
  end

  if tab_id == 'general' then
    local mode_val = opts.mode.choices[opts.mode.chosen]
    table.insert(
      items,
      Menu.item(
        '  Mode: ' .. mode_val,
        { type = 'select', path = 'mode', choices = opts.mode.choices }
      )
    )

    local picker_val = opts.picker.choices[opts.picker.chosen]
    table.insert(
      items,
      Menu.item(
        '  Picker: ' .. picker_val,
        { type = 'select', path = 'picker', choices = opts.picker.choices }
      )
    )

    local tab_val = opts.tab.choices[opts.tab.chosen]
    table.insert(
      items,
      Menu.item(
        '  Tab: ' .. tab_val,
        { type = 'select', path = 'tab', choices = opts.tab.choices }
      )
    )

    local explorer_val = opts.explorer.choices[opts.explorer.chosen]
    table.insert(
      items,
      Menu.item(
        '  Explorer: ' .. explorer_val,
        { type = 'select', path = 'explorer', choices = opts.explorer.choices }
      )
    )

    table.insert(items, Menu.separator '── Settings ──')
    local proxy_val = opts.settings.proxy
    table.insert(
      items,
      Menu.item(
        '  Proxy: ' .. proxy_val,
        { type = 'input', path = 'settings.proxy', prompt = 'Proxy' }
      )
    )
    local gemini_val = opts.settings.gemini_api_key
    table.insert(
      items,
      Menu.item('  Gemini API Key: ' .. gemini_val, {
        type = 'input',
        path = 'settings.gemini_api_key',
        prompt = 'Gemini API Key',
      })
    )
    local bash_val = opts.settings.win_bash_path
    table.insert(
      items,
      Menu.item('  Windows Bash Path: ' .. bash_val, {
        type = 'input',
        path = 'settings.win_bash_path',
        prompt = 'Windows Bash Path',
      })
    )
  elseif tab_id == 'theme' then
    local theme = opts.theme
    table.insert(
      items,
      Menu.item(
        ' ' .. enabled_icon(theme.enabled) .. ' Enable Theme',
        { type = 'toggle', path = 'theme.enabled' }
      )
    )
    table.insert(items, Menu.separator '───────────')
    local theme_val = theme.choices[theme.chosen]
    table.insert(
      items,
      Menu.item(
        '  Theme: ' .. theme_val,
        { type = 'select', path = 'theme', choices = theme.choices }
      )
    )
    local variants = theme.theme_variants[theme_val]
    if variants then
      local variant_val = variants.choices[variants.chosen]
      table.insert(
        items,
        Menu.item('  Variant: ' .. variant_val, {
          type = 'select',
          path = 'theme.theme_variants.' .. theme_val,
          choices = variants.choices,
          apply_theme = true,
        })
      )
    end
  elseif tab_id == 'plugin' then
    local ui = opts.plugins.ui
    local language = opts.plugins.language
    local git = opts.plugins.git
    local util = opts.plugins.util
    local ai = opts.plugins.ai
    local extra = opts.plugins.extra

    table.insert(items, Menu.separator '── UI ──')
    table.insert(
      items,
      Menu.item(
        ' ' .. enabled_icon(ui.enable_all) .. ' Enable All ',
        { type = 'toggle', path = 'plugins.ui.enable_all' }
      )
    )
    for name, value in pairs(ui.components) do
      table.insert(
        items,
        Menu.item(
          ' ' .. enabled_icon(value or ui.enable_all) .. ' ' .. name,
          { type = 'toggle', path = 'plugins.ui.components.' .. name }
        )
      )
    end

    table.insert(items, Menu.separator '── Lauguage ──')
    table.insert(
      items,
      Menu.item(
        ' ' .. enabled_icon(language.enable_all) .. ' Enable All ',
        { type = 'toggle', path = 'plugins.language.enable_all' }
      )
    )
    for name, value in pairs(language.components) do
      if name == 'basic' or name == 'debug' then
        table.insert(
          items,
          Menu.item(
            ' '
              .. enabled_icon(value.enabled or language.enable_all)
              .. ' '
              .. name,
            {
              type = 'toggle',
              path = 'plugins.language.components.' .. name .. '.enabled',
            }
          )
        )
      else
        table.insert(
          items,
          Menu.item(
            ' ' .. enabled_icon(value or language.enable_all) .. ' ' .. name,
            { type = 'toggle', path = 'plugins.language.components.' .. name }
          )
        )
      end
    end

    table.insert(items, Menu.separator '── Git ──')
    table.insert(
      items,
      Menu.item(
        ' ' .. enabled_icon(git.enable_all) .. ' Enable All ',
        { type = 'toggle', path = 'plugins.git.enable_all' }
      )
    )
    for name, value in pairs(git.components) do
      table.insert(
        items,
        Menu.item(
          ' ' .. enabled_icon(value or git.enable_all) .. ' ' .. name,
          { type = 'toggle', path = 'plugins.git.components.' .. name }
        )
      )
    end

    table.insert(items, Menu.separator '── Util ──')
    table.insert(
      items,
      Menu.item(
        ' ' .. enabled_icon(util.enable_all) .. ' Enable All ',
        { type = 'toggle', path = 'plugins.util.enable_all' }
      )
    )
    for name, value in pairs(util.components) do
      table.insert(
        items,
        Menu.item(
          ' ' .. enabled_icon(value or util.enable_all) .. ' ' .. name,
          { type = 'toggle', path = 'plugins.util.components.' .. name }
        )
      )
    end

    table.insert(items, Menu.separator '── AI ──')
    table.insert(
      items,
      Menu.item(
        ' ' .. enabled_icon(ai.enable_all) .. ' Enable All ',
        { type = 'toggle', path = 'plugins.ai.enable_all' }
      )
    )
    for name, value in pairs(ai.components) do
      table.insert(
        items,
        Menu.item(
          ' ' .. enabled_icon(value or ai.enable_all) .. ' ' .. name,
          { type = 'toggle', path = 'plugins.ai.components.' .. name }
        )
      )
    end

    table.insert(items, Menu.separator '── Extra ──')
    for name, value in pairs(extra.components) do
      table.insert(
        items,
        Menu.item(
          ' ' .. enabled_icon(value) .. ' ' .. name,
          { type = 'toggle', path = 'plugins.extra.components.' .. name }
        )
      )
    end
  elseif tab_id == 'lsp' then
    local lsp = opts.plugins.language.components.basic.lsp_server
    local ts = opts.plugins.language.components.basic.treesitter
    local fmt = opts.plugins.language.components.basic.formatter
    local lt = opts.plugins.language.components.basic.linter
    table.insert(items, Menu.separator '── LSP ──')
    table.insert(
      items,
      Menu.item(' ' .. enabled_icon(lsp.use_all) .. ' Use All ', {
        type = 'toggle',
        path = 'plugins.language.components.basic.lsp_server.use_all',
      })
    )
    for name, value in pairs(lsp.servers) do
      table.insert(
        items,
        Menu.item(' ' .. enabled_icon(value or lsp.use_all) .. ' ' .. name, {
          type = 'toggle',
          path = 'plugins.language.components.basic.lsp_server.servers.'
            .. name,
        })
      )
    end
    table.insert(items, Menu.separator '── Treesitter ──')
    table.insert(
      items,
      Menu.item(' ' .. enabled_icon(ts.use_all) .. ' Use All ', {
        type = 'toggle',
        path = 'plugins.language.components.basic.treesitter.use_all',
      })
    )
    for name, value in pairs(ts.parsers) do
      table.insert(
        items,
        Menu.item(' ' .. enabled_icon(value or ts.use_all) .. ' ' .. name, {
          type = 'toggle',
          path = 'plugins.language.components.basic.treesitter.parsers.'
            .. name,
        })
      )
    end
    table.insert(items, Menu.separator '── Fomatter ──')
    table.insert(
      items,
      Menu.item(' ' .. enabled_icon(fmt.use_all) .. ' Use All ', {
        type = 'toggle',
        path = 'plugins.language.components.basic.formatter.use_all',
      })
    )
    for name, value in pairs(fmt.formatters) do
      table.insert(
        items,
        Menu.item(' ' .. enabled_icon(value or fmt.use_all) .. ' ' .. name, {
          type = 'toggle',
          path = 'plugins.language.components.basic.formatter.formatters.'
            .. name,
        })
      )
    end
    table.insert(items, Menu.separator '── Linter ──')
    table.insert(
      items,
      Menu.item(' ' .. enabled_icon(lt.use_all) .. ' Use All ', {
        type = 'toggle',
        path = 'plugins.language.components.basic.linter.use_all',
      })
    )
    for name, value in pairs(lt.linters) do
      table.insert(
        items,
        Menu.item(' ' .. enabled_icon(value or lt.use_all) .. ' ' .. name, {
          type = 'toggle',
          path = 'plugins.language.components.basic.linter.linters.' .. name,
        })
      )
    end
  end

  return items
end

-- Show selection submenu
local function show_select_submenu(item, on_done)
  local Menu = require 'nui.menu'
  local choices = item.choices
  local path = item.path
  local current_chosen = get_nested(working_options, path .. '.chosen') or 1

  local menu_items = {}
  for i, choice in ipairs(choices) do
    local prefix = (i == current_chosen) and ' ' or ' '
    table.insert(menu_items, Menu.item(' ' .. prefix .. choice, { idx = i }))
  end

  local menu = Menu({
    position = '50%',
    size = { width = 30, height = math.min(#choices + 2, 12) },
    border = {
      style = 'rounded',
      text = { top = '[Select]', top_align = 'center' },
    },
  }, {
    lines = menu_items,
    keymap = {
      focus_next = { 'j', '<Down>' },
      focus_prev = { 'k', '<Up>' },
      close = { 'q', '<Esc>' },
      submit = { '<Space>' },
    },
    on_submit = function(selected)
      set_nested(working_options, path .. '.chosen', selected.idx)
      if
        item.apply_theme
        and not utils.find_value(
          working_options.theme.choices[working_options.theme.chosen],
          {
            'everforest',
            'material',
            'onenord',
            'nordic',
          }
        )
      then
        pcall(vim.cmd.colorscheme, choices[selected.idx])
      end
      on_done()
    end,
    on_close = on_done,
  })

  menu:mount()
end

local function show_input_panel(item, on_done)
  local Input = require 'nui.input'
  local path = item.path
  local current_val = get_nested(working_options, path) or ''
  local prompt = item.prompt

  local input = Input({
    position = '50%',
    size = {
      width = 50,
    },
    border = {
      style = 'rounded',
      text = {
        top = prompt,
        top_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
    },
  }, {
    prompt = ' ',
    default_value = current_val,
    on_close = on_done,
    on_submit = function(value)
      set_nested(working_options, path, value)
      on_done()
    end,
  })

  input:map('n', '<Esc>', function()
    input:unmount()
  end, { noremap = true })
  input:map('n', 'q', function()
    input:unmount()
  end, { noremap = true })

  input:mount()
end

-- Main settings menu
local function show_main_menu(restore_cursor)
  local Menu = require 'nui.menu'

  -- Build tab header
  local tab_header = ''
  for i, tab in ipairs(tabs) do
    if i == current_tab_idx then
      tab_header = tab_header .. '[' .. tab.label .. '] '
    else
      tab_header = tab_header .. ' ' .. tab.label .. '  '
    end
  end

  local items = build_menu_lines(tabs[current_tab_idx].id)
  -- first tow lines are empty, which will be covered by tab line
  table.insert(items, 1, Menu.item '')
  table.insert(items, 1, Menu.item '')

  local last_cursor = nil

  local menu = Menu({
    position = '50%',
    size = { width = 65, height = 25 },
    border = {
      style = 'rounded',
      text = {
        top = '  Nvim Settings ',
        top_align = 'center',
        bottom = '<Tab>: Change Tabs | <Space>: Select | <s>: Save | <r>: Reset',
        bottom_align = 'center',
      },
    },
    win_options = {
      cursorline = false,
    },
  }, {
    lines = items,
    keymap = {
      focus_next = { 'j', '<Down>' },
      focus_prev = { 'k', '<Up>' },
      close = { 'q', '<Esc>' },
      submit = { '<Space>' },
    },
    on_submit = function(item)
      if item.type == 'toggle' then
        local current = get_nested(working_options, item.path) or false
        set_nested(working_options, item.path, not current)
        show_main_menu(last_cursor) -- Refresh with cursor position
      elseif item.type == 'select' then
        show_select_submenu(item, function()
          show_main_menu(last_cursor)
        end)
      elseif item.type == 'input' then
        show_input_panel(item, function()
          show_main_menu(last_cursor)
        end)
      end
    end,
  })

  -- Tab switching
  menu:map('n', '<Tab>', function()
    current_tab_idx = current_tab_idx % #tabs + 1
    menu:unmount()
    show_main_menu()
  end, { noremap = true })

  menu:map('n', '<S-Tab>', function()
    current_tab_idx = (current_tab_idx - 2) % #tabs + 1
    menu:unmount()
    show_main_menu()
  end, { noremap = true })

  -- Save
  menu:map('n', 's', function()
    vim.g.options = working_options
    local opts_cache_path = vim.fn.stdpath 'config' .. '/opts_cache.json'
    utils.write_options(opts_cache_path)
    vim.notify(
      'Settings saved! Restart Neovim to apply.',
      vim.log.levels.INFO,
      { title = 'Nvim Settings' }
    )
  end, { noremap = true })

  -- Reset
  menu:map('n', 'r', function()
    local opts_default_path = vim.fn.stdpath 'config' .. '/opts_default.json'
    utils.read_options(opts_default_path)
    working_options = deep_copy(vim.g.options)
    menu:unmount()
    vim.notify(
      'Reset to default settings',
      vim.log.levels.INFO,
      { title = 'Nvim Settings' }
    )
    show_main_menu()
  end, { noremap = true })

  menu:mount()

  -- Track cursor position while menu is open
  vim.api.nvim_create_autocmd('CursorMoved', {
    buffer = menu.bufnr,
    callback = function()
      if menu.winid and vim.api.nvim_win_is_valid(menu.winid) then
        last_cursor = vim.api.nvim_win_get_cursor(menu.winid)
      end
    end,
  })

  -- Set header line (first line shows tabs)
  vim.schedule(function()
    local ns = vim.api.nvim_create_namespace 'nvim_settings_header'
    vim.api.nvim_buf_set_extmark(menu.bufnr, ns, 0, 0, {
      virt_text = { { tab_header, 'Title' } },
      virt_text_pos = 'overlay',
    })

    -- default to line 3
    vim.api.nvim_win_set_cursor(menu.winid, { 3, 0 })

    if restore_cursor then
      local line =
        math.min(restore_cursor[1], vim.api.nvim_buf_line_count(menu.bufnr))
      vim.api.nvim_win_set_cursor(menu.winid, { line, restore_cursor[2] })
    end
  end)
end

function M.open()
  local ok, err = pcall(function()
    working_options = deep_copy(vim.g.options)
    current_tab_idx = 1
    show_main_menu()
  end)

  if not ok then
    vim.notify(
      'Error opening settings: ' .. tostring(err),
      vim.log.levels.ERROR
    )
  end
end

return M
