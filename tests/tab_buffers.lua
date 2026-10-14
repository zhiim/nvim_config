-- Run from the config root:
-- nvim --headless -u NONE -i NONE -n -c 'luafile tests/tab_buffers.lua'
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.o.hidden = true
vim.o.swapfile = false

local api = vim.api
local tests = {}
local serial = 0

local function buffer(listed, buftype)
  serial = serial + 1
  local buf = api.nvim_create_buf(listed ~= false, false)
  api.nvim_buf_set_name(buf, '/tab-buffers-test-' .. serial)
  if buftype == 'terminal' then
    api.nvim_open_term(buf, {})
  else
    vim.bo[buf].buftype = buftype or ''
  end
  return buf
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

local function reset()
  flush()
  pcall(api.nvim_del_augroup_by_name, 'nvim_tab_buffers')
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
  package.loaded['utils.tab_buffers'] = nil
  return require 'utils.tab_buffers'
end

local function test(name, callback)
  tests[#tests + 1] = { name = name, run = callback }
end

test(
  'require is inert; defaults, order, deduplication and copied lists',
  function(m)
    equal(#api.nvim_get_autocmds { event = 'TabEnter' }, 0)
    local a, b = buffer(), buffer()
    local tab = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(a)
    assert(m.attach())
    assert(m.attach(0, b))
    assert(not m.attach(tab, a))
    assert(m.contains(nil, 0))
    equal(m.list(), { a, b })
    local copy = m.list()
    table.remove(copy, 1)
    equal(m.list(tab), { a, b })
  end
)

test(
  'membership is shared; detach does not touch windows or options',
  function(m)
    local a, b = buffer(), buffer()
    local first = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(a)
    m.attach(first, a)
    vim.cmd 'tabnew'
    local second = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(b)
    m.attach(second, a)
    assert(m.detach(first, a))
    assert(not m.detach(first, a))
    assert(m.contains(second, a))
    equal(api.nvim_tabpage_get_win(first) ~= 0, true)
    equal(api.nvim_win_get_buf(api.nvim_tabpage_get_win(first)), a)
    assert(api.nvim_buf_is_loaded(a) and vim.bo[a].buflisted)
  end
)

test(
  'replace handles order, duplicates and exclusions without touching other tabs',
  function(m)
    local a, b = buffer(), buffer()
    local unlisted = buffer(false)
    local special = buffer(true, 'nofile')
    local acwrite = buffer(true, 'acwrite')
    local first = api.nvim_get_current_tabpage()
    m.attach(first, a)
    vim.cmd 'tabnew'
    local second = api.nvim_get_current_tabpage()
    assert(m.replace(second, { b, b, unlisted, special, acwrite, a }))
    equal(m.list(second), { b, acwrite, a })
    equal(m.list(first), { a })
    assert(m.replace(second, {}))
    equal(m.list(second), {})
  end
)

test(
  'setup seeds existing windows but not pre-existing hidden buffers',
  function(m)
    local a, hidden = buffer(), buffer()
    local first = api.nvim_get_current_tabpage()
    api.nvim_set_current_buf(a)
    vim.cmd 'tabnew'
    local second = api.nvim_get_current_tabpage()
    local b = buffer()
    api.nvim_set_current_buf(b)
    m.setup()
    equal(m.list(first), { a })
    equal(m.list(second), { b })
    assert(not m.contains(first, hidden))
    m.setup()
    equal(m.list(first), { a })
    equal(m.list(second), { b })
  end
)

test(
  'automatic tracking retains hidden buffers and isolates new tabs',
  function(m)
    m.setup()
    local first = api.nvim_get_current_tabpage()
    local a, b = buffer(), buffer()
    api.nvim_set_current_buf(a)
    api.nvim_set_current_buf(b)
    assert(m.contains(first, a) and m.contains(first, b))
    vim.cmd 'tabnew'
    local second = api.nvim_get_current_tabpage()
    flush()
    assert(not m.contains(second, a))
    api.nvim_set_current_buf(a)
    assert(m.contains(first, a) and m.contains(second, a))
    assert(not m.contains(second, b))
  end
)

test('float and preview windows do not attach their buffers', function(m)
  m.setup()
  local tab = api.nvim_get_current_tabpage()
  local a = buffer()
  local float = api.nvim_open_win(a, true, {
    relative = 'editor',
    row = 1,
    col = 1,
    width = 10,
    height = 2,
  })
  assert(not m.contains(tab, a))
  flush()
  assert(not m.contains(tab, a))
  api.nvim_win_close(float, true)
  vim.cmd 'pedit /tab-buffers-preview-test'
  local preview
  for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
    if vim.wo[win].previewwindow then
      preview = win
    end
  end
  assert(preview, 'pedit did not create a preview window')
  local pbuf = api.nvim_win_get_buf(preview)
  assert(not m.contains(tab, pbuf))
  local b = buffer()
  api.nvim_win_set_buf(preview, b)
  api.nvim_set_current_win(preview)
  flush()
  assert(not m.contains(tab, b))
end)

test(
  'special buffers are rejected, including buffers converted after entry',
  function(m)
    m.setup()
    local tab = api.nvim_get_current_tabpage()
    for _, buftype in ipairs {
      'nofile',
      'help',
      'quickfix',
      'terminal',
      'prompt',
    } do
      assert(not m.attach(tab, buffer(true, buftype)))
    end
    local a = buffer()
    api.nvim_set_current_buf(a)
    assert(m.contains(tab, a))
    vim.bo[a].buftype = 'nofile'
    assert(not m.contains(tab, a))
    assert(not vim.tbl_contains(m.list(tab), a))
  end
)

test(
  'setting a background ordinary window buffer attaches to its tab',
  function(m)
    m.setup()
    local first = api.nvim_get_current_tabpage()
    local win = api.nvim_get_current_win()
    vim.cmd 'tabnew'
    local second = api.nvim_get_current_tabpage()
    local a = buffer()
    api.nvim_win_set_buf(win, a)
    assert(m.contains(first, a))
    assert(not m.contains(second, a))
  end
)

test(
  'nested pauses prevent automatic attachment; explicit replacement still works',
  function(m)
    m.setup()
    local tab = api.nvim_get_current_tabpage()
    local a, b, c = buffer(), buffer(), buffer()
    m.pause()
    m.pause()
    api.nvim_set_current_buf(a)
    assert(not m.contains(tab, a))
    assert(m.replace(tab, { b }))
    m.resume()
    api.nvim_set_current_buf(c)
    assert(not m.contains(tab, c))
    m.resume()
    equal(m.list(tab), { b })
    api.nvim_set_current_buf(a)
    assert(m.contains(tab, a))
    assert(not pcall(m.resume))
  end
)

test(
  'tab splits share the displayed buffer and membership survives reordering',
  function(m)
    m.setup()
    local first = api.nvim_get_current_tabpage()
    local a = buffer()
    api.nvim_set_current_buf(a)
    vim.cmd 'tab split'
    local second = api.nvim_get_current_tabpage()
    flush()
    assert(m.contains(first, a) and m.contains(second, a))
    vim.cmd 'tabmove 0'
    assert(m.contains(first, a) and m.contains(second, a))
  end
)

test('pausing or replacing invalidates pending window tracking', function(m)
  m.setup()
  local a, b = buffer(), buffer()
  api.nvim_set_current_buf(a)
  vim.cmd 'tab split'
  local second = api.nvim_get_current_tabpage()
  m.pause()
  m.resume()
  flush()
  assert(not m.contains(second, a))
  api.nvim_set_current_tabpage(api.nvim_list_tabpages()[1])
  api.nvim_set_current_tabpage(second)
  assert(m.replace(second, { b }))
  flush()
  equal(m.list(second), { b })
end)

test('real buffer deletion cleans all tabs, even while paused', function(m)
  m.setup()
  local a = buffer()
  local first = api.nvim_get_current_tabpage()
  m.attach(first, a)
  vim.cmd 'tabnew'
  local second = api.nvim_get_current_tabpage()
  m.attach(second, a)
  m.pause()
  api.nvim_buf_delete(a, { force = true })
  m.resume()
  assert(not m.contains(first, a) and not m.contains(second, a))
  assert(not m.detach(first, a) and not m.detach(second, a))
end)

test('unload retains membership; unlisting removes it', function(m)
  m.setup()
  local tab = api.nvim_get_current_tabpage()
  local a = buffer()
  m.attach(tab, a)
  api.nvim_buf_delete(a, { unload = true })
  assert(m.contains(tab, a))
  vim.bo[a].buflisted = false
  assert(not m.contains(tab, a))
  vim.bo[a].buflisted = true
  assert(not m.contains(tab, a))
end)

test('closing a tab preserves buffers and other tab memberships', function(m)
  m.setup()
  local first = api.nvim_get_current_tabpage()
  local a = buffer()
  m.attach(first, a)
  vim.cmd 'tabnew'
  local closed = api.nvim_get_current_tabpage()
  m.attach(closed, a)
  vim.cmd 'tabclose'
  assert(api.nvim_buf_is_valid(a) and vim.bo[a].buflisted)
  assert(m.contains(first, a))
  equal(m.list(closed), {})
  assert(not m.detach(closed, a))
  assert(not m.attach(closed, a))
  assert(not m.replace(closed, { a }))
end)

test('switching tabs does not emit buffer lifecycle events', function(m)
  local a, b = buffer(), buffer()
  local first = api.nvim_get_current_tabpage()
  api.nvim_set_current_buf(a)
  vim.cmd 'tabnew'
  local second = api.nvim_get_current_tabpage()
  api.nvim_set_current_buf(b)
  m.setup()
  local events = {}
  local group =
    api.nvim_create_augroup('tab_buffers_test_events', { clear = true })
  api.nvim_create_autocmd(
    { 'BufAdd', 'BufDelete', 'BufUnload', 'BufWipeout' },
    {
      group = group,
      callback = function(event)
        events[#events + 1] = event.event
      end,
    }
  )
  for _ = 1, 3 do
    api.nvim_set_current_tabpage(first)
    api.nvim_set_current_tabpage(second)
  end
  equal(events, {})
  assert(vim.bo[a].buflisted and vim.bo[b].buflisted)
  api.nvim_del_augroup_by_id(group)
end)

local failures = 0
for _, case in ipairs(tests) do
  local ok, err = xpcall(function()
    case.run(reset())
  end, debug.traceback)
  if ok then
    print('PASS: ' .. case.name)
  else
    failures = failures + 1
    print('FAIL: ' .. case.name .. '\n' .. err)
  end
end
print(string.format('%d/%d tests passed', #tests - failures, #tests))
if failures > 0 then
  vim.cmd 'cquit 1'
else
  vim.cmd 'qa!'
end
