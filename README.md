# Neovim Configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

## Getting Started

### Pre-requisites

- [Nerd Font](https://www.nerdfonts.com/)
- Git
- GCC
- Make
- tree-sitter-cli (if use nvim-treesitter)
- Ripgrep (if use telescope)
- fzf (if use fzf-lua)
- Python (optional, to use LSP)
- Node.js (optional, to use Prettier)
- fd (optioanl, to use venv_selector and fzf-lua)
- llvm and MSVC (optional, C++ in windows)
- optional for fzf-lua: bat, delta

### Install

```bash
# Linux
git clone https://github.com/zhiim/nvim_config.git ~/.config/nvim
# Windows
git clone https://github.com/zhiim/nvim_config.git $ENV:USERPROFILE\AppData\Local\nvim

nvim
```

## Configure

### Neovim Setting

`lua/config/options.lua`

### Key Mapping

`lua/config/mapping.lua` and `keys` in plugin configs.

### Plugin Management

Plugin system is built with [lazy.nvim](https://github.com/folke/lazy.nvim).

Add plugins by editing `lua/plugins/init.lua`. Or add a `{plugin_name}.lua` file in `lua/plugins/configs` and require it in `lua/plugins/init.lua`.

Open lazy.nvim panel with command `:Lazy`.

### Add Language Support

#### Language Parsers

Built with [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter).

Modify `nvim-treesitter.opts.ensure_installed` in `lua/plugins/language/treesitter.lua`.

Treesitter usage:

- `:TSUpdate {language}/all` to update Parsers
- `:TSInstallInfo` to check installation information for different languages
- `TSUninstall <package_to_uninstall>` to remove an installed package

#### LSP, Linter and Formatter Management

[Mason](https://github.com/williamboman/mason.nvim) is used to management language support packages.

Add new packages by modifying `vim.list_extend(ensure_installed, {})` in `lua/plugins/configs/language/lspconfig.lua`.

Open Mason panel by `:Mason` command.

Mason usage:

- `:Mason` - opens a graphical status window
- `:MasonUpdate` - updates all managed registries
- `:MasonInstall <package> ...` - installs/re-installs the provided packages
- `:MasonUninstall <package> ...` - uninstalls the provided packages
- `:MasonUninstallAll` - uninstalls all packages
- `:MasonLog` - opens the mason.nvim log file in a new tab window

#### LSP Configuration

LSP configuration support is built with [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).

Add LSP name to `servers` in `lua/plugins/configs/language/lspconfig.lua` (check [server_configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#clangd) for support for specific LSP).

#### Format & Lint

Formatter is built with [conform.nvim](https://github.com/stevearc/conform.nvim).

Lintter is built with [nvim-lint](https://github.com/mfussenegger/nvim-lint).

Trun on a formatter or linter by editing `lua/plugins/configs/language/conform.lua` for formatter and `lua/plugins/configs/language/lint.lua` for linter.

#### Debugging Support

`nvim-dap`, `nvim-dap-ui` plugin have been added for debugging. Plugins for specific language debugging can be found in [Debug Adapter installation](https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation).

### Tips

- To share clipboard with system, install `xclip` on Linux with X11. But install `win32yank` and uninstall `xclip` for WSL.
- If `nvim-treesitter` output error `Invalid node type at position x for language x`, you can use `:echo nvim_get_runtime_file('parser', v:true)` to check whether more than one parser is used or not, than rename the nvim parser folder to another name to use treesitter parser only.
- set venv searching path by modify `conda_command` and `venv_command` in `lua/plugins/config/venv_selector.lua`
- Debugging C/C++ in Windows with codelldb need a program compiled using `clang` with `--target=x86_64-pc-windows-gnu`
- To use `fish` in Windows, set `bash_path` and auto start `fish` every time entering `bash`
- To use plugins that depend on `curl` within MSYS bash, you need to use mingw curl. A solution is set `MSYSTEM` to `MINGW64` in `/etc/msystem` and `/etc/fish/msystem.fish`
