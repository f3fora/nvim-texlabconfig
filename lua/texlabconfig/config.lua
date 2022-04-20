local vim = vim

local defaults = {
    cache_activate = true,
    cache_filetypes = { 'tex', 'bib' },
    cache_root = vim.fn.stdpath('cache'),
    reverse_search_edit_cmd = 'edit',
    file_permission_mode = 438,
}

local M = {}

function M.setup(user_config)
    defaults = vim.tbl_deep_extend('force', defaults, user_config)
end

function M.get()
    return defaults
end

return M
