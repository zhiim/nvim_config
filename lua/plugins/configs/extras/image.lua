return {
  '3rd/image.nvim',
  ft = { 'markdown' },
  enabled = vim.fn.has 'linux',
  build = false,
  opts = {
    backend = 'kitty',
    processor = 'magick_cli', -- or "magick_cli"
  },
}
