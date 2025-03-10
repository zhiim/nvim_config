return {
  'Wansmer/symbol-usage.nvim',
  -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
  event = function()
    if vim.fn.has 'nvim-0.10' then
      return 'LspAttach'
    else
      return 'BufReadPre'
    end
  end,
  enabled = function()
    return vim.fn.has 'nvim-0.9' and vim.g.options.enhance
  end,
  config = function()
    local function text_format(symbol)
      local res = {}

      local round_start = { '', 'SymbolUsageRounding' }
      local round_end = { '', 'SymbolUsageRounding' }

      -- Indicator that shows if there are any other symbols in the same line
      local stacked_functions_content = symbol.stacked_count > 0
          and ('+%s'):format(symbol.stacked_count)
        or ''

      if symbol.references then
        local usage = symbol.references <= 1 and 'usage' or 'usages'
        local num = symbol.references == 0 and 'no' or symbol.references
        table.insert(res, round_start)
        table.insert(res, { '󰌹 ', 'SymbolUsageRef' })
        table.insert(
          res,
          { ('%s %s'):format(num, usage), 'SymbolUsageContent' }
        )
        table.insert(res, round_end)
      end

      if symbol.definition then
        if #res > 0 then
          table.insert(res, { ' ', 'NonText' })
        end
        table.insert(res, round_start)
        table.insert(res, { '󰳽 ', 'SymbolUsageDef' })
        table.insert(
          res,
          { symbol.definition .. ' defs', 'SymbolUsageContent' }
        )
        table.insert(res, round_end)
      end

      if symbol.implementation then
        if #res > 0 then
          table.insert(res, { ' ', 'NonText' })
        end
        table.insert(res, round_start)
        table.insert(res, { '󰡱 ', 'SymbolUsageImpl' })
        table.insert(
          res,
          { symbol.implementation .. ' impls', 'SymbolUsageContent' }
        )
        table.insert(res, round_end)
      end

      if stacked_functions_content ~= '' then
        if #res > 0 then
          table.insert(res, { ' ', 'NonText' })
        end
        table.insert(res, round_start)
        table.insert(res, { ' ', 'SymbolUsageImpl' })
        table.insert(res, { stacked_functions_content, 'SymbolUsageContent' })
        table.insert(res, round_end)
      end

      return res
    end

    ---@diagnostic disable-next-line: missing-fields
    require('symbol-usage').setup {
      vt_position = 'end_of_line',
      references = { enabled = true, include_declaration = false },
      definition = { enabled = true },
      implementation = { enabled = true },
      text_format = text_format,
    }
  end,
}
