local vim = vim

local utils = require('texlabconfig.utils')
local cache = require('texlabconfig.cache')

local M = {}

function M:str_inverse_search_cmd(str)
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
    for _, server in ipairs(cache:servernames()) do
        local ok, socket = pcall( --
            vim.fn.sockconnect,
            'pipe',
            server,
            { rpc = true }
        )
        if ok then
            vim.rpcrequest( --
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
    end
end

return M
