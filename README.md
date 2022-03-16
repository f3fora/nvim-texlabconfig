# nvim-texlabconfig

**Texlab** is a popular Language Server for LaTeX, which supports **Forward Search** and **Inverse Search** between TeX and PDF files.

**nvim-texlabconfig** provides some useful snippets to configure this capability for **neovim** and some viewers.

## Requirements

- [nvim](https://github.com/neovim/neovim) 0.7+
- [TexLab](https://github.com/latex-lsp/texlab)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

## Installation

**nvim-texlabconfig** can be installed for example with [Packer](https://github.com/wbthomason/packer.nvim) and should be loaded only when required.

```lua
use({
    'f3fora/nvim-texlabconfig',
    config = function()
        require('texlabconfig').setup(config)
    end,
    ft = { 'tex', 'bib' },
    cmd = { 'TexlabInverseSearch' },
})
```

## Configuration

**nvim-texlabconfig** is configured using the `setup` function. The argument is a table and is optional. The default values are listed below.

```lua
local config = {
    cache_activate = true,
    cache_filetypes = { 'tex', 'bib' },
    cache_root = vim.fn.stdpath('cache'),
    reverse_search_edit_cmd = 'edit',
}
```

### `cache_activate`

Do not change this option.

Type: boolean
Default: `true`

### `cache_filetypes`

Activate cache for buffers with these file types.

Type: list of strings
Default: `{ 'tex', 'bib' }`

### `cache_root`

Specify the cache directory. **nvim-texlabconfig** creates a `nvim-texlabconfig.json` file in this directory.

Type: string
Default: `vim.fn.stdpath('cache')`

### `reverse_search_edit_cmd`

When working in a multi-file project, initiating inverse search may require opening a file that is not currently open in a window. This option controls the command that is used to open files as a result of an inverse search.

Type: string
Default: `'edit'`
Examples:

- `'edit'` open buffer in current window
- `'tabedit'` open buffer in new tab page
- `'split'` split current window to open buffer

## Status

WIP. Help wanted to add and test other viewers, which are present in [Texlab Previewing Documentation](https://github.com/latex-lsp/texlab/blob/master/docs/previewing.md).

## Previewing

To configure Forward and Inverse Search, the default configuration of `texlab` defined in [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#texlab) has to be changed.

Different values of `executable` and `args` are required for each viewer.

```lua
local lspconfig = require('lspconfig')
local executable
local args

lspconfig.texlab.setup({
    setting = {
        texlab = {
            forwardSearch = {
                executable = executable,
                args = args,
            },
        },
    },
})
```

In the following sections, some configurations are reported.

### Zathura

```lua
local executable = 'zathura'
local args = {
    '--synctex-editor-command',
    [[nvim --headless -c 'TexlabInverseSearch %{input} %{line}']],
    '--synctex-forward',
    '%l:1:%f',
    '%p',
}
```

## Commands

### `TexlabInverseSearch`

`TexlabInverseSearch` is a convenient command which simplifies the viewer configuration. It handles multiple neovim instances and choose the correct server names.

The command takes two arguments: `%f` as absolute filename and `%l` as line number, and can be used from a remote neovim session.

```sh
nvim --headless -c 'TexlabInverseSearch %f %l'
```

## Credit

- [VimTeX](https://github.com/lervag/vimtex)
