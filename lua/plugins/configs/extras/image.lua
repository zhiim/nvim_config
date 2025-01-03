return {
  '3rd/image.nvim',
  ft = { 'markdown' },
  enabled = (vim.fn.has 'linux' == 1) and (vim.fn.has 'wsl' == 0),
  build = false,
  opts = {
    backend = 'kitty',
    processor = 'magick_cli', -- or "magick_cli"
  },
}
