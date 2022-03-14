local vim = vim

local function cache_root()
    return (vim.env.XDG_CACHE_HOME or (vim.env.HOME .. '/.cache'))
end

local defaults = {
    cache_root = cache_root(),
    reverse_search_edit_cmd = 'edit',
}

local M = {}

function M.setup(user_config)
    defaults = vim.tbl_deep_extend('force', defaults, user_config)
end

function M.get()
    return defaults
end

return M
