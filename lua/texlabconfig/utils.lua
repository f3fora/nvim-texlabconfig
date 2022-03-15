local vim = vim

local M = {}

function M.file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        f:close()
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

function M.split(inputstr, sep)
    if sep == nil then
        sep = '%s'
    end
    local t = {}
    for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
        table.insert(t, tonumber(str) or str)
    end
    return t
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
return M
