return {
  'lervag/vimtex',
  ft = { 'tex', 'plaintex' },
  -- tag = "v2.15", -- uncomment to pin to a specific release
  enabled = vim.g.options.tex,
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.tex_flavor = 'latex'
    vim.g.vimtex_quickfix_mode = 0
    -- vim.g.vimtex_compiler_latexmk_engines = { _ = '-xelatex' }
    -- pdf viewer
    if vim.fn.has 'win32' == 1 then
      vim.g.vimtex_view_general_viewer = 'SumatraPDF'
      vim.g.vimtex_view_general_options =
        '-reuse-instance -forward-search @tex @line @pdf'
    else
      vim.g.vimtex_view_method = 'zathura'
    end
    -- change mapping prefix
    vim.g.vimtex_mappings_prefix = '<leader>v'
  end,
  dependencies = {
    'micangl/cmp-vimtex',
    enabled = vim.g.options.cmp == 'nvim_cmp',
    config = function()
      require('cmp').setup {
        sources = {
          { name = 'vimtex' },
        },
      }
      require('cmp_vimtex').setup {}
    end,
  },
}
