return {
  'gutsavgupta/nvim-gemini-companion',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    vim.keymap.set('n', 'q', function()
      if vim.bo.filetype == 'terminalGemini' then
        vim.cmd 'GeminiToggle'
      end
    end)
    require('gemini').setup()
  end,
  keys = {
    { '<leader>gmt', '<cmd>GeminiToggle<cr>', desc = 'Toggle Gemini sidebar' },
    {
      '<leader>gms',
      ":'<,'>GeminiSend<CR>",
      mode = { 'x' },
      desc = 'Send selection to Gemini',
    },
    {
      '<leader>gmf',
      '<cmd>GeminiSwitchSidebarStyle floating<cr>',
      desc = 'Open Gemini floating',
    },
    {
      '<leader>gms',
      '<cmd>GeminiSwitchSidebarStyle right-fixed<cr>',
      desc = 'Open Gemini sidebar',
    },
    {
      '<leader>gmd',
      '<cmd>GeminiSendLineDiagnostic<cr>',
      mode = { 'n', 'x' },
      desc = 'Send line diagnostic to Gemini',
    },
  },
}
