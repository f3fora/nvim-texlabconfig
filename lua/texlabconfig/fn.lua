local vim = vim

local utils = require('texlabconfig.utils')
local config = require('texlabconfig.config').get()

local M = {}

M.reverse_search_edit_cmd = config.reverse_search_edit_cmd

function M:inverse_search(filename, line)
    local file = vim.fn.resolve(filename)
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
        vim.cmd(self.reverse_search_edit_cmd .. file)
        i = i + 1
    end

    if i >= allow_fail then
        error('Max Iteration')
    end

    vim.api.nvim_set_current_win(win)
    vim.api.nvim_set_current_tabpage(tab)
    vim.api.nvim_win_set_cursor(win, { line, 0 })
end

return M
