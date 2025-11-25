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
      desc = 'Gemini Send selection',
    },
    {
      '<leader>gmd',
      '<cmd>GeminiSendLineDiagnostic<cr>',
      mode = { 'n', 'x' },
      desc = 'Gemini Send line diagnostic',
    },
    {
      '<leader>gma',
      '<cmd>GeminiAccept<cr>',
      mode = { 'n' },
      desc = 'Gemini Accept suggestion',
    },
    {
      '<leader>gmr',
      '<cmd>GeminiReject<cr>',
      mode = { 'n' },
      desc = 'Gemini Reject suggestion',
    },
  },
}
