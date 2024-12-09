local check_external_reqs = function()
  -- Basic utils: `git`, `make`, `unzip`
  for _, exe in ipairs { 'git', 'make', 'gcc', 'rg' } do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  if vim.g.options.language_support then
    for _, exe in ipairs { 'python', 'node', 'fd' } do
      local is_executable = vim.fn.executable(exe) == 1
      if is_executable then
        vim.health.ok(string.format("Found executable: '%s'", exe))
      else
        vim.health.warn(string.format("Could not find executable: '%s'", exe))
      end
    end
  end

  return true
end

return {
  check = function()
    vim.health.start 'Neovim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_external_reqs()
  end,
}
