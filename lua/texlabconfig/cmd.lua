local vim = vim

local utils = require('texlabconfig.utils')
local cache = require('texlabconfig.cache')

local M = {}

function M:str_inverse_search_cmd(str)
    -- TODO:
    -- check what happens when /path/to/file contains spaces
    local tbl = utils.split(str)
    if #tbl == 2 then
        self:inverse_search_cmd(unpack(tbl))
    end
end

function M:inverse_search_cmd(filename, line)
    if line > 0 and utils.file_exists(filename) then
        pcall(self._inverse_search_cmd, self, filename, line)
    end
    vim.cmd('quitall!')
end

function M:_inverse_search_cmd(filename, line)
    -- current: open overriding any tex file
    -- TODO:
    -- 1: check if files is already opened and go there
    -- 2: track from which windows is lauched TexlabForward and go there
    local result = false
    for _, server in ipairs(cache:servernames()) do
        local ok, socket = pcall( --
            vim.fn.sockconnect,
            'pipe',
            server,
            { rpc = true }
        )
        if ok and socket ~= 0 then
            -- vim.rpcnotify is non-blocking but does not allow any feedback value
            result = vim.rpcrequest( --
                socket,
                'nvim_exec_lua',
                [[
                return require('texlabconfig.fn'):inverse_search(...)
                ]],
                {
                    filename,
                    line,
                }
            )
        end
        pcall(vim.fn.chanclose, socket)
        -- return on first match
        if result then
            break
        end
    end
end

return M
