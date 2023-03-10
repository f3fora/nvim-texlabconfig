local vim = vim
local uv = vim.loop
local api = vim.api

local utils = require('texlabconfig.utils')

local M = {}

function M:inverse_search(filename, line)
    local config = require('texlabconfig.config').options

    if config.reverse_search_start_cmd() then
    else
        return false
    end

    local file = uv.fs_realpath(filename)
    local buf, win, tab

    local i = 1
    local allow_fail = 4
    while i < allow_fail do
        -- If the file is already open, move the cursor there.
        local ok
        ok, buf = pcall(utils.bufnr, file)
        if ok then
            ok, win = pcall(utils.winnr, buf)
            if ok then
                ok, tab = pcall(utils.tabnr, win)
                if ok then
                    break
                end
            end
        end
        -- Otherwise open it
        config.reverse_search_edit_cmd(file)
        i = i + 1
    end

    if i >= allow_fail then
        return false
    end

    if (1 > line) or (line > api.nvim_buf_line_count(buf)) then
        return false
    end

    api.nvim_set_current_win(win)
    api.nvim_set_current_tabpage(tab)
    api.nvim_win_set_cursor(win, { line, 0 })

    if config.reverse_search_end_cmd() then
    else
        return false
    end

    return true
end

return M
