return {
  'akinsho/toggleterm.nvim',
  lazy = true,
  cmd = 'ToggleTerm',
  keys = {
    -- toggleterm
    {
      '<A-u>',
      '<cmd>ToggleTerm direction=horizontal<CR>',
      mode = { 'n', 't' },
      desc = 'Terminal Toggle in horizontal',
    },
    {
      '<A-i>',
      '<cmd>ToggleTerm direction=float<CR>',
      mode = { 'n', 't' },
      desc = 'Terminal toggle in float',
    },
    {
      '<A-o>',
      '<cmd>ToggleTerm direction=vertical<CR>',
      mode = { 'n', 't' },
      desc = 'Terminal toggle in vertical',
    },
    {
      '<A-s>',
      function()
        local trim_spaces = true
        if vim.bo.ft == 'python' then
          trim_spaces = false -- keep spaces
        end
        require('toggleterm').send_lines_to_terminal(
          'visual_selection',
          trim_spaces,
          { args = vim.v.count }
        )
      end,
      mode = 'v',
      desc = 'Terminal send lines to terminal',
    },
  },
  config = function()
    require('toggleterm').setup {
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      highlights = {
        FloatBorder = {
          link = 'FloatBorder',
        },
      },
      open_mapping = [[<C-\>]],
      hide_numbers = true, -- hide the number column in toggleterm buffers
      shade_terminals = false,
      start_in_insert = true,
      insert_mappings = true, -- whether or not the open mapping applies in insert mode
      persist_size = true,
      direction = 'horizontal',
      close_on_exit = true, -- close the terminal window when the process exits
      shell = vim.o.shell, -- change the default shell
      float_opts = {
        border = 'curved',
        width = function()
          return math.floor(vim.api.nvim_list_uis()[1].width * 0.8)
        end,
        height = function()
          return math.floor(vim.api.nvim_list_uis()[1].height * 0.8)
        end,
      },
    }
  end,
}
