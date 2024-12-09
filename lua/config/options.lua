-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- set a column line to indicate line changing of code
vim.opt.colorcolumn = '80,120'

vim.opt.expandtab = true -- expand tab input with spaces characters
vim.opt.smartindent = true -- syntax aware indentations for newline inserts
vim.opt.tabstop = 4 -- num of space characters per tab
vim.opt.shiftwidth = 4 -- spaces per indentation level

-- Set highlight on search
vim.opt.hlsearch = true

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
vim.opt.whichwrap:append '<>[]hl'

-- disable some default providers
vim.g['loaded_node_provider'] = 0
vim.g['loaded_python3_provider'] = 0
vim.g['loaded_perl_provider'] = 0
vim.g['loaded_ruby_provider'] = 0

-- add binaries installed by mason.nvim to path
local is_windows = vim.fn.has 'win32' ~= 0
vim.env.PATH = vim.fn.stdpath 'data'
  .. '/mason/bin'
  .. (is_windows and ';' or ':')
  .. vim.env.PATH

-- use powershell in Windows
if is_windows then
  if
    vim.g.options.bash_path ~= ''
    and (vim.uv or vim.loop).fs_stat(vim.g.options.bash_path)
  then
    vim.o.shell = vim.g.options.bash_path .. ' -i' .. ' -l'
    vim.o.shellcmdflag = '-s'
  else
    vim.o.shell = vim.fn.executable 'pwsh' and 'pwsh' or 'powershell'
    vim.o.shellcmdflag =
      '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    vim.o.shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
    vim.o.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.o.shellquote = ''
    vim.o.shellxquote = ''
  end
end

vim.diagnostic.config {
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●',
    -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
    -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
    -- prefix = "icons",
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.HINT] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
    },
  },
}
