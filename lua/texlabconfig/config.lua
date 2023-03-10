local vim = vim

local defaults = {
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

local M = {}

M.options = {}

function M.setup(user_config)
    M.options = vim.tbl_deep_extend('force', defaults, user_config)
    vim.validate({
        cache_activate = { M.options.cache_activate, 'boolean' },
        cache_filetypes = { M.options.cache_filetypes, 'table' },
        cache_root = { M.options.cache_root, 'string' },
        reverse_search_start_cmd = { M.options.reverse_search_start_cmd, 'function' },
        reverse_search_edit_cmd = { M.options.reverse_search_edit_cmd, 'function' },
        reverse_search_end_cmd = { M.options.reverse_search_end_cmd, 'function' },
        file_permission_mode = { M.options.file_permission_mode, 'number' },
    })
end

return M
