local vim = vim
local uv = vim.loop
local api = vim.api

local utils = require('texlabconfig.utils')
local config = require('texlabconfig.config').get()

local M = {}

M.reverse_search_edit_cmd = config.reverse_search_edit_cmd

function M:inverse_search(filename, line)
    local file = uv.fs_realpath(filename)
    local buf, win, tab

    local i = 1
    local allow_fail = 4
    while i < allow_fail do
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
        self.reverse_search_edit_cmd(file)
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

    return true
end

return M
