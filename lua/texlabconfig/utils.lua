local vim = vim
local uv = vim.loop

local M = {}

function M.file_exists(name, mode)
    local fd = uv.fs_open(name, 'r', mode)
    if fd ~= nil then
        assert(uv.fs_close(fd))
        return true
    end

    return false
end

function M.bufnr(filename)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local _filename = vim.api.nvim_buf_get_name(buf)
        if _filename == filename then
            return buf
        end
    end
    error('No File')
end

function M.winnr(buf)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local _buf = vim.api.nvim_win_get_buf(win)
        if _buf == buf then
            return win
        end
    end
    error('No Buf')
end

function M.tabnr(win)
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local _win = vim.api.nvim_tabpage_get_win(tab)
        if _win == win then
            return tab
        end
    end
    error('No Win')
end

function M.list_unique(list)
    local hash = {}
    local res = {}

    for _, v in ipairs(list) do
        if not hash[v] then
            res[#res + 1] = v
            hash[v] = true
        end
    end

    return res
end

function M.project_dir()
    local paths = vim.api.nvim_list_runtime_paths()
    local init_path = debug.getinfo(1).source
    local dir
    local len = 0
    for _, path in ipairs(paths) do
        local current_len = path:len()
        if current_len > len and path == init_path:sub(2, 1 + current_len) then
            dir = path
            len = current_len
        end
    end
    return dir
end

return M
