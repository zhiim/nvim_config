if not vim.g.options.enhance then
  return {}
end

return {
  'skardyy/neo-img',
  build = function()
    require('neo-img').install()
  end,
  config = function()
    require('neo-img').setup {
      supported_extensions = {
        ['png'] = true,
        ['jpg'] = true,
        ['jpeg'] = true,
        ['webp'] = true,
        ['svg'] = true,
        ['tiff'] = true,
        ['tif'] = true,
        ['docx'] = false,
        ['xlsx'] = false,
        ['pdf'] = false,
        ['pptx'] = false,
      },
      auto_open = true,
      oil_preview = true,
      backend = 'auto',
      size = { -- size in pixels
        x = 400,
        y = 400,
      },
      offset = { -- offset in cells (rows / cols)
        x = 10,
        y = 3,
      },
      resizeMode = 'Fit', -- Fit / Strech / Crop
    }
    vim.keymap.set('n', '<leader>pi', function()
      local function get_string_under_cursor()
        local _, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()

        local start_col = line:sub(1, col):find '[\'"(]'
        local end_col = line:find('[\'")]', col + 1)

        if start_col and end_col then
          return line:sub(start_col + 1, end_col - 1)
        end
      end

      local function create_float_window()
        local buf = vim.api.nvim_create_buf(false, true)
        local width = 40
        local height = 10
        local opts = {
          style = 'minimal',
          border = 'rounded',
          relative = 'cursor',
          width = width,
          height = height,
          row = 0,
          col = 0,
          focusable = false,
        }
        -- do not enter float window
        local win = vim.api.nvim_open_win(buf, false, opts)
        -- Make the buffer non-editable
        vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
        -- Close the window when the cursor moves
        vim.cmd(
          string.format(
            'autocmd CursorMoved * ++once lua vim.api.nvim_win_close(%d, true)',
            win
          )
        )
        -- Set the filetype for the buffer
        vim.api.nvim_set_option_value(
          'filetype',
          'ttyimg-preview',
          { buf = buf }
        )
        -- close the window when pressing 'q'
        vim.api.nvim_buf_set_keymap(
          buf,
          'n',
          'q',
          '<cmd>bd!<CR>',
          { noremap = true, silent = true }
        )

        return win
      end

      local content = get_string_under_cursor()
      if content ~= nil and vim.loop.fs_stat(content) ~= nil then
        local win = create_float_window()
        require('neo-img.utils').display_image(content, win)
      end
    end, { desc = 'Preview image under cursor' })
  end,
}
