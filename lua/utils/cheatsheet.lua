local M = {}
local api = vim.api
local opt_local = vim.api.nvim_set_option_value

local ascii = {
  '                                      ',
  '                                      ',
  '                                      ',
  '█▀▀ █░█ █▀▀ ▄▀█ ▀█▀ █▀ █░█ █▀▀ █▀▀ ▀█▀',
  '█▄▄ █▀█ ██▄ █▀█ ░█░ ▄█ █▀█ ██▄ ██▄ ░█░',
  '                                      ',
  '                                      ',
  '                                      ',
}

-- only show cheatsheet mappings which are in these groups
local included_groups = {
  'Utils',
  'Terminal',
  'Options',
  'Tab',
  'Cmake',
  'Telescope',
  'FzfLua',
  'CommentBox',
  'Flash',
  'GrugFar',
  'MiniMap',
  'Resession',
  'Explorer',
  'Buffer',
  'Dropbar',
  'GotoPreview',
  'Trouble',
  'LSP',
  'Debug',
  'Git',
  'Copilot',
  'CodeCompanion',
  'DimMode',
  'Snacks',
  'Portal',
  'Grapple',
} -- can add group name or with mode

local state = {
  mappings_tb = {},
}

--- capitalize the first letter of a string
local function capitalize(str)
  return (str:gsub('^%l', string.upper))
end

local function append_mode(table, keybind, mode)
  for i, item in ipairs(table) do
    if item[2] == keybind then
      table[i][1] = item[1] .. ' (' .. mode .. ')'
      return table, true
    end
  end
  return table, false
end

local get_mappings = function(mappings, tb_to_add)
  for _, v in ipairs(mappings) do
    local desc = v.desc

    -- dont include mappings which have \n in their desc
    if
      not desc
      or (select(2, desc:gsub('%S+', '')) <= 1)
      or string.find(desc, '\n')
    then
      goto continue
    end

    local heading = desc:match '%S+' -- get first word

    -- useful for including groups
    if
      not (
        vim.tbl_contains(included_groups, heading)
        or vim.tbl_contains(included_groups, desc:match '%S+')
      )
    then
      goto continue
    end

    heading = capitalize(heading)

    -- if heading is not present in the table, add it
    if not tb_to_add[heading] then
      tb_to_add[heading] = {}
    end

    local keybind = string.sub(v.lhs, 1, 1) == ' ' and '<leader> +' .. v.lhs
      or v.lhs

    desc = v.desc:match '%s(.+)' -- remove first word from desc
    desc = capitalize(desc)

    -- if desc is already present in the table, dont add it
    local appended = false
    tb_to_add[heading], appended =
      append_mode(tb_to_add[heading], keybind, v.mode)
    if appended then
      goto continue
    end

    desc = desc .. ' (' .. v.mode .. ')'
    table.insert(tb_to_add[heading], { desc, keybind })

    ::continue::
  end
end

local organize_mappings = function()
  local tb_to_add = {}
  local modes = { 'i', 't', 'v', 'n' }

  for _, mode in ipairs(modes) do
    local keymaps = vim.api.nvim_get_keymap(mode)
    get_mappings(keymaps, tb_to_add)

    local bufkeymaps = vim.api.nvim_buf_get_keymap(0, mode)
    get_mappings(bufkeymaps, tb_to_add)
  end

  return tb_to_add
end

local rand_hlgroup = function()
  local hlgroups =
    { 'Blue', 'Red', 'Green', 'Yellow', 'Orange', 'Magenta', 'Cyan' }

  return 'Back' .. hlgroups[math.random(1, #hlgroups)]
end

-- drwaing with extmarks, can't search mappings, can auto resize

-- normal drawing, can search mappings, can't auto resize
function M.draw()
  local cheatsheet = api.nvim_create_namespace 'cheatsheet'

  state.mappings_tb = organize_mappings()

  local buf = api.nvim_create_buf(false, true)
  local win = api.nvim_get_current_win()

  api.nvim_set_current_win(win)

  -- add left padding (strs) to ascii so it looks centered
  local ascii_header = vim.tbl_values(ascii)

  vim.wo[win].winhl = 'NormalFloat:Normal'

  local ascii_padding = (api.nvim_win_get_width(win) / 2)
    - (#ascii_header[1] / 2)

  for i, str in ipairs(ascii_header) do
    ascii_header[i] = string.rep(' ', ascii_padding) .. str
  end

  -- set ascii
  api.nvim_buf_set_lines(buf, 0, -1, false, ascii_header)

  -- column width
  local column_width = 0
  for _, section in pairs(state.mappings_tb) do
    for _, mapping in pairs(section) do
      local txt = vim.fn.strdisplaywidth(mapping[1] .. mapping[2])
      column_width = column_width > txt and column_width or txt
    end
  end

  -- 10 = space between mapping txt , 4 = 2 & 2 space around mapping txt
  column_width = column_width + 10

  local win_width = vim.o.columns
    - vim.fn.getwininfo(api.nvim_get_current_win())[1].textoff
    - 4

  local columns_qty = math.floor(win_width / column_width)
  columns_qty = (win_width / column_width < 10 and columns_qty == 0) and 1
    or columns_qty

  column_width = math.floor(
    (win_width - (column_width * columns_qty)) / columns_qty
  ) + column_width

  -- add mapping tables with their headings as key names
  local cards = {}
  local card_headings = {}

  for name, section in pairs(state.mappings_tb) do
    for _, mapping in ipairs(section) do
      local padding_left =
        math.floor((column_width - vim.fn.strdisplaywidth(name)) / 2)

      -- center the heading
      name = string.rep(' ', padding_left)
        .. name
        .. string.rep(
          ' ',
          column_width - vim.fn.strdisplaywidth(name) - padding_left
        )

      table.insert(card_headings, name)

      if not cards[name] then
        cards[name] = {}
      end

      table.insert(cards[name], string.rep(' ', column_width))

      local whitespace_len = column_width
        - 4
        - vim.fn.strdisplaywidth(mapping[1] .. mapping[2])
      local pretty_mapping = mapping[1]
        .. string.rep(' ', whitespace_len)
        .. mapping[2]

      table.insert(cards[name], '  ' .. pretty_mapping .. '  ')
    end

    table.insert(cards[name], string.rep(' ', column_width))
    table.insert(cards[name], string.rep(' ', column_width))
  end

  -- divide cheatsheet layout into columns
  local columns = {}

  for i = 1, columns_qty, 1 do
    columns[i] = {}
  end

  local function getColumn_height(tb)
    local res = 0

    for _, value in pairs(tb) do
      res = res + #value + 1
    end

    return res
  end

  local function append_table(tb1, tb2)
    for _, val in ipairs(tb2) do
      tb1[#tb1 + 1] = val
    end
  end

  local cards_headings_sorted = vim.tbl_keys(cards)

  -- imitate masonry layout
  for _, heading in ipairs(cards_headings_sorted) do
    for column, mappings in ipairs(columns) do
      if column == 1 and getColumn_height(columns[1]) == 0 then
        columns[1][1] = cards_headings_sorted[1]
        append_table(columns[1], cards[cards_headings_sorted[1]])
        break
      elseif
        column == 1
        and (
          getColumn_height(mappings) < getColumn_height(columns[#columns])
          or getColumn_height(mappings) == getColumn_height(columns[#columns])
        )
      then
        columns[column][#columns[column] + 1] = heading
        append_table(columns[column], cards[heading])
        break
      elseif
        column ~= 1
        and (getColumn_height(columns[column - 1]) > getColumn_height(mappings))
      then
        if not vim.tbl_contains(columns[1], heading) then
          columns[column][#columns[column] + 1] = heading
          append_table(columns[column], cards[heading])
        end
        break
      end
    end
  end

  local longest_column = 0

  for _, value in ipairs(columns) do
    longest_column = longest_column > #value and longest_column or #value
  end

  local max_col_height = 0

  -- get max_col_height
  for _, value in ipairs(columns) do
    max_col_height = max_col_height < #value and #value or max_col_height
  end

  -- fill empty lines with whitespaces
  -- so all columns will have the same height
  for i, _ in ipairs(columns) do
    for _ = 1, max_col_height - #columns[i], 1 do
      columns[i][#columns[i] + 1] = string.rep(' ', column_width)
    end
  end

  local result = vim.tbl_values(columns[1])

  -- merge all the column strings
  for index, value in ipairs(result) do
    local line = value

    for col_index = 2, #columns, 1 do
      line = line .. '  ' .. columns[col_index][index]
    end

    result[index] = line
  end

  api.nvim_buf_set_lines(buf, #ascii_header, -1, false, result)

  -- add highlight to the columns
  for i = 0, max_col_height, 1 do
    for column_i, _ in ipairs(columns) do
      local col_start = column_i == 1 and 0
        or (column_i - 1) * column_width + ((column_i - 1) * 2)

      if columns[column_i][i] then
        -- highlight headings & one line after it
        if vim.tbl_contains(card_headings, columns[column_i][i]) then
          local lines = api.nvim_buf_get_lines(
            buf,
            i + #ascii_header - 1,
            i + #ascii_header + 1,
            false
          )

          -- highlight area around card heading
          api.nvim_buf_add_highlight(
            buf,
            cheatsheet,
            'ChSection',
            i + #ascii_header - 1,
            vim.fn.byteidx(lines[1], col_start),
            vim.fn.byteidx(lines[1], col_start)
              + column_width
              + vim.fn.strlen(columns[column_i][i])
              - vim.fn.strdisplaywidth(columns[column_i][i])
          )
          -- highlight card heading & randomize hl groups for colorful colors
          api.nvim_buf_add_highlight(
            buf,
            cheatsheet,
            rand_hlgroup(),
            i + #ascii_header - 1,
            vim.fn.stridx(lines[1], vim.trim(columns[column_i][i]), col_start)
              - 1,
            vim.fn.stridx(lines[1], vim.trim(columns[column_i][i]), col_start)
              + vim.fn.strlen(vim.trim(columns[column_i][i]))
              + 1
          )
          api.nvim_buf_add_highlight(
            buf,
            cheatsheet,
            'ChSection',
            i + #ascii_header,
            vim.fn.byteidx(lines[2], col_start),
            vim.fn.byteidx(lines[2], col_start) + column_width
          )

          -- highlight mappings & one line after it
        elseif
          string.match(columns[column_i][i], '%s+') ~= columns[column_i][i]
        then
          local lines = api.nvim_buf_get_lines(
            buf,
            i + #ascii_header - 1,
            i + #ascii_header + 1,
            false
          )
          api.nvim_buf_add_highlight(
            buf,
            cheatsheet,
            'ChSection',
            i + #ascii_header - 1,
            vim.fn.stridx(lines[1], columns[column_i][i], col_start),
            vim.fn.stridx(lines[1], columns[column_i][i], col_start)
              + vim.fn.strlen(columns[column_i][i])
          )
          api.nvim_buf_add_highlight(
            buf,
            cheatsheet,
            'ChSection',
            i + #ascii_header,
            vim.fn.byteidx(lines[2], col_start),
            vim.fn.byteidx(lines[2], col_start) + column_width
          )
        end
      end
    end
  end

  -- set highlights for  ascii header
  for i = 0, #ascii_header - 1, 1 do
    api.nvim_buf_add_highlight(buf, cheatsheet, 'ChAsciiHeader', i, 0, -1)
  end

  api.nvim_set_current_buf(buf)

  -- set a clean page
  opt_local('buflisted', false, { scope = 'local' })
  opt_local('modifiable', false, { scope = 'local' })
  opt_local('buftype', 'nofile', { buf = buf })
  opt_local('number', false, { scope = 'local' })
  opt_local('list', false, { scope = 'local' })
  opt_local('wrap', false, { scope = 'local' })
  opt_local('relativenumber', false, { scope = 'local' })
  opt_local('cursorline', false, { scope = 'local' })
  opt_local('colorcolumn', '0', { scope = 'local' })
  opt_local('foldcolumn', '0', { scope = 'local' })
  opt_local('ft', 'cheatsheet', { buf = buf })
  vim.g['cheatsheet' .. '_displayed'] = true

  vim.keymap.set('n', 'q', function()
    if vim.g.options.enhance then
      Snacks.bufdelete()
    else
      vim.cmd 'bp|sp|bn|bd!'
    end
  end, { buffer = buf })
end

return M
