-- Run from the config root with installed bufferline/resession/fzf-lua:
-- nvim --headless -u NONE -i NONE -n -c 'luafile tests/tab_buffer_integrations.lua'
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local plugin_dir = vim.env.NVIM_TEST_PLUGIN_DIR
  or vim.fn.stdpath 'data' .. '/lazy'
for _, plugin in ipairs {
  'resession.nvim',
  'bufferline.nvim',
  'fzf-lua',
  'nvim-web-devicons',
} do
  vim.opt.runtimepath:append(plugin_dir .. '/' .. plugin)
end
vim.o.hidden = true
vim.o.swapfile = false
vim.g.mapleader = ' '

local api = vim.api
local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
-- Keep all session writes in the test's temporary directory.
local original_stdpath = vim.fn.stdpath
vim.fn.stdpath = function(kind)
  if kind == 'data' then
    return root
  end
  return original_stdpath(kind)
end

local cases = {}
local serial = 0
local function test(name, run)
  cases[#cases + 1] = { name = name, run = run }
end
local function equal(actual, expected)
  assert(
    vim.deep_equal(actual, expected),
    'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual)
  )
end
local function flush()
  vim.wait(10, function()
    return false
  end)
end
local function choose(tab, picker)
  vim.g.options = {
    tab = { choices = { tab }, chosen = 1 },
    picker = { choices = { picker or 'fzf_lua' }, chosen = 1 },
    mode = { chosen = 1 },
    plugins = { util = { enable_all = false, components = {} } },
  }
end
local function reset()
  flush()
  vim.cmd 'silent! tabonly!'
  vim.cmd 'silent! only!'
  vim.wo.previewwindow = false
  vim.cmd 'enew!'
  local current = api.nvim_get_current_buf()
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if buf ~= current then
      api.nvim_buf_delete(buf, { force = true })
    end
  end
  choose 'bufferline'
end
local function file()
  serial = serial + 1
  local name = root .. '/file-' .. serial .. '.txt'
  vim.fn.writefile({ 'test line ' .. serial }, name)
  local buf = vim.fn.bufadd(name)
  vim.fn.bufload(buf)
  vim.bo[buf].buflisted = true
  return buf, name
end
local function names(tab)
  local ret = {}
  for _, buf in ipairs(require('utils.tab_buffers').list(tab)) do
    ret[#ret + 1] = api.nvim_buf_get_name(buf)
  end
  return ret
end

local function with_modules(modules, run)
  local previous = {}
  for name, module in pairs(modules) do
    previous[name] = package.loaded[name]
    package.loaded[name] = module
  end
  local ok, err = xpcall(run, debug.traceback)
  for name in pairs(modules) do
    package.loaded[name] = previous[name]
  end
  if not ok then
    error(err)
  end
end

test(
  'option gating preserves barbar/tabby session and picker defaults',
  function()
    local maps, setup_opts = {}, nil
    local old_set = vim.keymap.set
    vim.keymap.set = function(_, lhs, rhs)
      maps[lhs] = rhs
    end
    local noop = function() end
    local builtin = setmetatable({}, {
      __index = function()
        return noop
      end,
    })
    local mocks = {
      ['telescope'] = { setup = noop, load_extension = noop },
      ['telescope.actions'] = { close = noop },
      ['telescope.themes'] = {
        get_dropdown = function()
          return {}
        end,
      },
      ['telescope.builtin'] = builtin,
      ['fzf-lua'] = { setup = noop, register_ui_select = noop, actions = {} },
      ['resession'] = {
        setup = function(opts)
          setup_opts = opts
        end,
      },
    }
    local ok, err = pcall(function()
      with_modules(mocks, function()
        for _, tab in ipairs { 'barbar', 'tabby' } do
          for _, picker in ipairs { 'telescope', 'fzf_lua' } do
            choose(tab, picker)
            maps = {}
            local session = dofile 'lua/plugins/configs/session.lua'
            equal(session.opts(), {})
            session.config(nil, session.opts())
            equal(setup_opts, {})
            dofile('lua/plugins/configs/picker.lua').config()
            equal(
              maps['<leader>sb'],
              picker == 'telescope' and '<cmd>Telescope buffers<cr>'
                or '<cmd>FzfLua buffers<cr>'
            )
            assert(maps['<leader>sB'] == nil)
            assert(not require('utils.tab_buffers').enabled())
            assert(
              not pcall(api.nvim_get_autocmds, { group = 'nvim_tab_buffers' })
            )
          end
        end
        for _, picker in ipairs { 'telescope', 'fzf_lua' } do
          choose('bufferline', picker)
          maps = {}
          dofile('lua/plugins/configs/picker.lua').config()
          assert(type(maps['<leader>sb']) == 'function')
          assert(maps['<leader>sB'])
          assert(type(maps['<leader>sa']) == 'function')
          local opts = dofile('lua/plugins/configs/session.lua').opts()
          equal(opts.extensions.tab_buffers, { enable_in_tab = true })
          assert(type(opts.tab_buf_filter) == 'function')
        end
      end)
    end)
    vim.keymap.set = old_set
    if not ok then
      error(err)
    end
  end
)

test(
  'real bufferline filters navigation and closes only the current tab view',
  function()
    local spec = dofile 'lua/plugins/configs/tab.lua'
    spec.init()
    spec.config()
    local tabs = require 'utils.tab_buffers'
    local a, b, foreign = file(), file(), file()
    local first = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(a)
    api.nvim_set_current_buf(b)
    tabs.replace(first, { a, b })
    vim.cmd 'tabnew'
    local second = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(foreign)
    tabs.replace(second, { foreign, a })
    api.nvim_set_current_tabpage(first)
    local config = require('bufferline.config').options
    assert(config.custom_filter(a) and config.custom_filter(b))
    assert(not config.custom_filter(foreign))
    vim.bo[b].filetype = 'dap-repl'
    assert(not config.custom_filter(b))
    vim.bo[b].filetype = ''
    local bufferline = require 'bufferline'
    api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true })
    local elements = bufferline.get_elements().elements
    equal(
      vim.tbl_map(function(e)
        return e.id
      end, elements),
      { a, b }
    )
    bufferline.cycle(-1)
    equal(api.nvim_get_current_buf(), a)
    config.close_command(a)
    flush()
    assert(not tabs.contains(first, a) and tabs.contains(second, a))
    assert(api.nvim_buf_is_valid(a) and vim.bo[a].buflisted)
    equal(api.nvim_get_current_buf(), b)
  end
)

test(
  'closing the last modified buffer refuses deletion and preserves its view',
  function()
    local tabs = require 'utils.tab_buffers'
    local a = file()
    local tab = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(a)
    api.nvim_buf_set_lines(a, 0, -1, false, { 'unsaved' })
    tabs.replace(tab, { a })
    assert(not pcall(tabs.close, tab, a))
    flush()
    assert(
      api.nvim_buf_is_valid(a) and vim.bo[a].modified and vim.bo[a].buflisted
    )
    assert(tabs.contains(tab, a))
    equal(api.nvim_get_current_buf(), a)
  end
)

test(
  'close updates every window in its tab and resumes tracking after errors',
  function()
    local tabs = require 'utils.tab_buffers'
    local a, b = file(), file()
    local tab = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(a)
    vim.cmd 'vsplit'
    tabs.replace(tab, { a, b })
    assert(tabs.close(tab, a))
    for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
      equal(api.nvim_win_get_buf(win), b)
    end
    assert(not api.nvim_buf_is_loaded(a))
    a = file()
    api.nvim_set_current_buf(a)
    local original = api.nvim_win_set_buf
    api.nvim_win_set_buf = function()
      error 'simulated window error'
    end
    local ok = pcall(tabs.close, tab, a)
    api.nvim_win_set_buf = original
    assert(not ok and tabs.contains(tab, a))
    local c = file()
    api.nvim_set_current_buf(c)
    assert(tabs.contains(tab, c))
  end
)

test(
  'real fzf-lua file actions add newly listed buffers to bufferline',
  function()
    local tabs = require 'utils.tab_buffers'
    tabs.setup()
    local actions = require 'fzf-lua.actions'
    for _, action in ipairs {
      actions.file_edit,
      actions.file_split,
      actions.file_vsplit,
      actions.file_tabedit,
    } do
      local first = api.nvim_get_current_tabpage()
      local original = file()
      api.nvim_set_current_buf(original)
      tabs.replace(first, { original })
      serial = serial + 1
      local name = root .. '/fzf-selected-' .. serial .. '.txt'
      vim.fn.writefile({ 'selected file' }, name)
      -- fzf-lua uses bufadd(), enters the unlisted buffer, then lists it.
      action({ name }, { no_action_zz = true })
      local selected = api.nvim_get_current_buf()
      local target = api.nvim_get_current_tabpage()
      equal(api.nvim_buf_get_name(selected), name)
      assert(vim.bo[selected].buflisted)
      assert(tabs.contains(target, selected))
      assert(tabs.contains(first, original))
      if target ~= first then
        assert(not tabs.contains(first, selected))
        assert(not tabs.contains(target, original))
      end
      api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true })
      local ids = vim.tbl_map(function(element)
        return element.id
      end, require('bufferline').get_elements().elements)
      assert(vim.tbl_contains(ids, selected))
    end
  end
)

local function setup_session()
  local spec = dofile 'lua/plugins/configs/session.lua'
  spec.config(nil, spec.opts())
  return require 'resession'
end
local function two_tabs()
  local tabs = require 'utils.tab_buffers'
  local a, an = file()
  local hidden, hn = file()
  local b, bn = file()
  local first = api.nvim_get_current_tabpage()
  api.nvim_set_current_buf(a)
  tabs.replace(first, { hidden, a })
  vim.cmd 'tabnew'
  local second = api.nvim_get_current_tabpage()
  api.nvim_set_current_buf(b)
  tabs.replace(second, { b, a })
  return { { hn, an }, { bn, an } }, first, second
end

test(
  'real resession full-session roundtrip restores hidden/shared membership and order',
  function()
    local resession = setup_session()
    local expected = two_tabs()
    resession.save('full', { notify = false })
    local data = vim.json.decode(
      table.concat(vim.fn.readfile(root .. '/session/full.json'), '\n')
    )
    equal(data.tab_buffers.tabs, expected)
    resession.load 'full'
    flush()
    local tabpages = api.nvim_list_tabpages()
    equal(#tabpages, 2)
    equal(names(tabpages[1]), expected[1])
    equal(names(tabpages[2]), expected[2])
    local extra = file()
    api.nvim_set_current_buf(extra)
    assert(require('utils.tab_buffers').contains(nil, extra))
  end
)

test(
  'real resession tab-session excludes foreign hidden buffers and preserves existing tabs',
  function()
    local resession = setup_session()
    local expected, first, second = two_tabs()
    api.nvim_set_current_tabpage(first)
    resession.save_tab('single', { notify = false })
    local data = vim.json.decode(
      table.concat(vim.fn.readfile(root .. '/session/single.json'), '\n')
    )
    equal(data.tab_buffers.tabs, { expected[1] })
    local saved = vim.tbl_map(function(buf)
      return buf.name
    end, data.buffers)
    assert(not vim.tbl_contains(saved, expected[2][1]))
    resession.load 'single'
    flush()
    equal(#api.nvim_list_tabpages(), 3)
    equal(names(first), expected[1])
    equal(names(second), expected[2])
    equal(names(api.nvim_get_current_tabpage()), expected[1])
  end
)

test(
  'real resession reset=false maps multiple inserted tabs without overwriting neighbors',
  function()
    local resession = setup_session()
    local expected, first, second = two_tabs()
    resession.save('append', { notify = false })
    api.nvim_set_current_tabpage(first)
    resession.load('append', { reset = false })
    flush()
    local tabpages = api.nvim_list_tabpages()
    equal(#tabpages, 4)
    equal(names(first), expected[1])
    equal(names(second), expected[2])
    local inserted = {}
    for _, tab in ipairs(tabpages) do
      if tab ~= first and tab ~= second then
        inserted[#inserted + 1] = tab
      end
    end
    equal(names(inserted[1]), expected[1])
    equal(names(inserted[2]), expected[2])
  end
)

test(
  'legacy sessions seed visible buffers only; missing sessions do not pause tracking',
  function()
    local resession = setup_session()
    two_tabs()
    resession.save('legacy', { notify = false })
    local filename = root .. '/session/legacy.json'
    local data = vim.json.decode(table.concat(vim.fn.readfile(filename), '\n'))
    data.tab_buffers = nil
    vim.fn.writefile({ vim.json.encode(data) }, filename)
    resession.load 'legacy'
    flush()
    for _, tab in ipairs(api.nvim_list_tabpages()) do
      equal(#names(tab), 1)
      local buf = api.nvim_win_get_buf(api.nvim_tabpage_get_win(tab))
      assert(require('utils.tab_buffers').contains(tab, buf))
    end
    assert(not pcall(resession.load, 'missing'))
    local a = file()
    api.nvim_set_current_buf(a)
    assert(require('utils.tab_buffers').contains(nil, a))
  end
)

test(
  'picker adapters capture tab scope and avoid empty project-wide grep',
  function()
    local tabs = require 'utils.tab_buffers'
    tabs.setup()
    local a, an = file()
    local foreign = file()
    local first = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(a)
    tabs.replace(first, { a })
    local captured = {}
    with_modules({
      ['fzf-lua'] = {
        buffers = function(opts)
          captured.buffers = opts
        end,
        lines = function(opts)
          captured.lines = opts
        end,
      },
      ['telescope.builtin'] = {
        buffers = function(opts)
          captured.telescope = opts
        end,
        live_grep = function(opts)
          captured.grep = opts
        end,
      },
      ['telescope.make_entry'] = {
        gen_from_buffer = function()
          return function(entry)
            return entry
          end
        end,
      },
    }, function()
      local picker = require 'utils.tab_buffer_picker'
      picker.fzf_buffers()
      picker.fzf_lines()
      picker.telescope_buffers()
      picker.telescope_live_grep()
      equal(captured.grep.search_dirs, { an })
      vim.cmd 'tabnew'
      api.nvim_set_current_buf(foreign)
      for _, opts in ipairs { captured.buffers, captured.lines } do
        assert(opts.filter(a) and not opts.filter(foreign))
      end
      assert(captured.telescope.entry_maker { bufnr = a })
      assert(not captured.telescope.entry_maker { bufnr = foreign })
      tabs.replace(api.nvim_get_current_tabpage(), {})
      captured.grep = nil
      picker.telescope_live_grep()
      assert(captured.grep == nil)
    end)
  end
)

test(
  'real fzf-lua provider filters hidden and visible buffers through its native API',
  function()
    local tabs = require 'utils.tab_buffers'
    local a, an = file()
    local hidden, hn = file()
    local foreign, fn = file()
    api.nvim_set_current_buf(a)
    tabs.replace(api.nvim_get_current_tabpage(), { a, hidden })
    local fzf = require 'fzf-lua'
    fzf.setup { buffers = { file_icons = false } }
    local core = require 'fzf-lua.core'
    local utils = require 'fzf-lua.utils'
    utils.clear_CTX()
    utils.CTX { includeBuflist = true }
    local original_exec = core.fzf_exec
    local entries = {}
    core.fzf_exec = function(contents)
      contents(function(entry)
        if entry then
          entries[#entries + 1] = entry
        end
      end)
    end
    local ok, err = pcall(require('utils.tab_buffer_picker').fzf_buffers)
    core.fzf_exec = original_exec
    utils.clear_CTX()
    if not ok then
      error(err)
    end
    local output = table.concat(entries, '\n')
    assert(output:find(vim.fn.fnamemodify(an, ':t'), 1, true))
    assert(output:find(vim.fn.fnamemodify(hn, ':t'), 1, true))
    assert(not output:find(vim.fn.fnamemodify(fn, ':t'), 1, true))
    assert(api.nvim_buf_is_valid(foreign))
  end
)

local failures = 0
for _, case in ipairs(cases) do
  local ok, err = xpcall(function()
    reset()
    case.run()
  end, debug.traceback)
  if ok then
    print('PASS: ' .. case.name)
  else
    failures = failures + 1
    print('FAIL: ' .. case.name .. '\n' .. err)
  end
end
vim.fn.stdpath = original_stdpath
vim.fn.delete(root, 'rf')
print(
  string.format('%d/%d integration tests passed', #cases - failures, #cases)
)
vim.cmd(failures == 0 and 'qa!' or 'cquit 1')
