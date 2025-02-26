# nvim-texlabconfig

**Texlab** is a popular Language Server for LaTeX, which supports **Forward Search** and **Inverse Search** between TeX and PDF files.

**nvim-texlabconfig** provides some useful snippets to configure this capability for **neovim** and some viewers and a homonymous executable which allows a fast **Inverse Search**.

## Requirements

- [nvim](https://github.com/neovim/neovim) 0.8+
- [TexLab](https://github.com/latex-lsp/texlab)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [go](https://go.dev/)

### Tags

- `v0.1.0` does not depend on `go` for building purpose and does not require an additional executable
- `v0.2.0` is compatible with nvim 0.7
- `v0.2.1` adds the `-server` flag

## Installation

**nvim-texlabconfig** can be installed for example with [lazy.nvim](https://github.com/folke/lazy.nvim).

```lua
{
    'f3fora/nvim-texlabconfig',
    config = function()
        require('texlabconfig').setup(config)
    end,
    -- ft = { 'tex', 'bib' }, -- Lazy-load on filetype
    build = 'go build'
    -- build = 'go build -o ~/.bin/' -- if e.g. ~/.bin/ is in $PATH
}
```

Calling `require('texlabconfig').setup()` is required and can eventually be [configured with a table](#configuration).

The executable `nvim-texlabconfig` has to be also build, e.g., with `go build`. By default, the result can be found in `:lua =require('texlabconfig').project_dir()` directory. However, the output location can be chosen with `-o` flag. From `go help build`:

> The -o flag forces build to write the resulting executable or object to the named output file or directory, instead of the default behavior described in the last two paragraphs. If the named output is an existing directory or ends with a slash or backslash, then any resulting executables will be written to that directory.`

## Configuration

**nvim-texlabconfig** is configured using the `setup` function. The argument is a table and is optional. The default values are listed below.

```lua
local config = {
    cache_activate = true,
    cache_filetypes = { 'tex', 'bib' },
    cache_root = vim.fn.stdpath('cache'),
    reverse_search_start_cmd = function()
        return true
    end,
    reverse_search_edit_cmd = vim.cmd.edit,
    reverse_search_end_cmd = function()
        return true
    end,
    file_permission_mode = 438,
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

Type: function(file_path: string)
Default: `vim.cmd.edit`
Examples:

- `vim.cmd.edit` open buffer in current window
- `vim.cmd.tabedit` open buffer in new tab page
- `vim.cmd.split` split current window to open buffer

### `reverse_search_{start,end}_cmd`

Execute a custom function at the beginning or at end of the inverse search process.
If the return value of this function if false or nil, the inverse search fails.

Type: function()  
Default: `function() return true end`

### `file_permission_mode`

See [luv-file-system-operations](https://github.com/luvit/luv/blob/master/docs.md#file-system-operations=).

Type: integer
Default: `438`

## Executable: `nvim-texlabconfig`

`nvim-texlabconfig` is a convenient executable which simplifies the viewer configuration. It handles multiple neovim instances and choose the correct one.

Assuming `nvim-texlabconfig` is placed in a `$PATH` directory and `cache_root` is the default one, the following command can be used, where `%f` is the absolute filename and `%l` is the line number.

```sh
nvim-texlabconfig -file '%f' -line %l
```

Otherwise, if `nvim-texlabconfig` is not in `$PATH`, e.g. it is placed in `:lua =require('texlabconfig').project_dir()`,

```sh
/path/to/nvim-texlabconfig -file '%f' -line %l
```

If a different [`cache_root`](#cache_root) is used, the directory used has to be specified after `-cache_root` optional flag. This flag is useful in macOS. See e.g. [Skim](#skim).

```sh
nvim-texlabconfig -file '%f' -line %l -cache_root /path/to/cache_root/
```

An optional flag `-server` is used to open the TeX file in the right neovim instance while working with multiple PDF documents. See e.g. [Zathura](#zathura).

```sh
nvim-texlabconfig -file '%f' -line %l -server `vim.v.servername`
```

From `nvim-texlabconfig -help` on Linux:

> Usage of nvim-texlabconfig:
> -cache_root string
> Path to nvim-texlabconfig.json file (default "/home/user/.cache/nvim")
> -file string
> Absolute filename [REQUIRED]
> -line int
> Line number [REQUIRED]
> -server string
> Server name (vim.v.servername)

## Status

Help wanted to add and test other viewers, which are present in [Texlab Previewing Documentation](https://github.com/latex-lsp/texlab/wiki/Previewing).

## Previewing

To configure Forward and Inverse Search, the default configuration of `texlab` defined in [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#texlab) has to be changed.

Different values of `executable` and `args` are required for each viewer.

> **Warning**
> `args` will be escaped in some strange way.

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

### [Sioyek](https://sioyek.info/)

```lua
executable = "sioyek",
args = {
    "--reuse-window",
    "--execute-command",
    "toggle_synctex", -- Open Sioyek in synctex mode.
    "--inverse-search",
    'nvim-texlabconfig -file "%%%1" -line "%%%2" -server ' .. vim.v.servername,
    "--forward-search-file",
    "%f",
    "--forward-search-line",
    "%l",
    "%p",
}
```

From [Sioyek documentation](https://sioyek-documentation.readthedocs.io/en/latest/usage.html#synctex):

> Press `f4` to toggle synctex mode (`toggle_synctex` command). While in this mode, **right clicking** on any text opens the corresponding `tex` file in the appropriate location.

### [Skim](https://skim-app.sourceforge.io/)

```lua
local executable = '/Applications/Skim.app/Contents/SharedSupport/displayline'
local args = { '%l', '%p', '%f' }
```

In the Skim preferences (Skim → Preferences → Sync → PDF-TeX Sync support)

```
Preset: Custom
Command: nvim-texlabconfig
Arguments: -file '%file' -line %line -cache_root $cache_root
```

Replace `$cache_root` with the `require('texlabconfig.config').get().cache_root`, whose default value is `vim.fn.stdpath('cache')`, which uses XDG directory specifications on macOS rather than Standard Directories guidelines and returns `~/.cache/nvim/`.

### [Zathura](https://pwmt.org/projects/zathura/)

```lua
local executable = 'zathura'
local args = {
    '--synctex-editor-command',
    [[nvim-texlabconfig -file '%%%{input}' -line %%%{line} -server ]] .. vim.v.servername,
    '--synctex-forward',
    '%l:1:%f',
    '%p',
}
```
