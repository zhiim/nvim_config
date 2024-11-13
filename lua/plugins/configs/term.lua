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
      desc = 'Toggle terminal in horizontal',
    },
    {
      '<A-i>',
      '<cmd>ToggleTerm direction=float<CR>',
      mode = { 'n', 't' },
      desc = 'Toggle terminal in float',
    },
    {
      '<A-o>',
      '<cmd>ToggleTerm direction=vertical<CR>',
      mode = { 'n', 't' },
      desc = 'Toggle terminal in vertical',
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
        width = function()
          return math.floor(vim.api.nvim_list_uis()[1].width * 0.9)
        end,
        height = function()
          return math.floor(vim.api.nvim_list_uis()[1].height * 0.9)
        end,
      },
    }
  end,
}
