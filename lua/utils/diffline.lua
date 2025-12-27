local M = {}

local diff_saved_text = nil
local diff_saved_filetype = nil

local function disable_diag_lsp(bufnr)
  -- disable diagnostics
  if vim.diagnostic.enable then
    vim.diagnostic.enable(false, { bufnr = bufnr })
  else
    vim.diagnostic.disable(bufnr)
  end

  -- disable lsp clients
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    local clients = vim.lsp.get_clients { bufnr = bufnr }
    for _, client in ipairs(clients) do
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
  end)
end

local function create_buf(buf, filetype, file_content)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  if filetype then
    vim.bo[buf].filetype = filetype
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(file_content, '\n'))
  disable_diag_lsp(buf)
  vim.keymap.set('n', 'q', '<cmd>tabclose<cr>', {
    buffer = buf,
    silent = true,
  })
end

function M.diff_selection()
  -- copy selected text to register 'v'
  vim.cmd 'noau normal! "vy'

  local current_text = vim.fn.getreg 'v'
  local current_ft = vim.bo.filetype

  if diff_saved_text == nil then
    -- 1. first time run, save the first selection
    diff_saved_text = current_text
    diff_saved_filetype = current_ft
    print 'Selected segment saved. Please select the second text to diff.'
  else
    -- 2. second time run, get the second selection and show diff
    local first_text = diff_saved_text
    local first_ft = diff_saved_filetype

    -- reset saved variables
    diff_saved_text = nil
    diff_saved_filetype = nil

    -- create new tab for diff
    vim.cmd 'tabnew'

    local buf1 = vim.api.nvim_get_current_buf()
    create_buf(buf1, first_ft, first_text)
    -- do diff
    vim.cmd 'diffthis'

    -- split window for second buffer
    vim.cmd 'vnew'
    local buf2 = vim.api.nvim_get_current_buf()
    create_buf(buf2, current_ft, current_text)
    vim.cmd 'diffthis'
  end
end

return M
