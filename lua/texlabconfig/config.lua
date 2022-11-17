local vim = vim

local defaults = {
    cache_activate = true,
    cache_filetypes = { 'tex', 'bib' },
    cache_root = vim.fn.stdpath('cache'),
    reverse_search_edit_cmd = vim.cmd.edit,
    file_permission_mode = 438,
}

local M = {}

function M.setup(user_config)
    defaults = vim.tbl_deep_extend('force', defaults, user_config)
    vim.validate({
        cache_activate = { defaults.cache_activate, 'boolean' },
        cache_filetypes = { defaults.cache_filetypes, 'table' },
        cache_root = { defaults.cache_root, 'string' },
        reverse_search_edit_cmd = { defaults.reverse_search_edit_cmd, 'function' },
        file_permission_mode = { defaults.file_permission_mode, 'number' },
    })
end

function M.get()
    return defaults
end

return M
