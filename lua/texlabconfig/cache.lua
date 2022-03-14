local vim = vim
local json = vim.json
local create_augroup = vim.api.nvim_create_augroup
local create_autocmd = vim.api.nvim_create_autocmd

local config = require('texlabconfig.config').get()

local M = {}

M.fname = config.cache_root .. '/nvim-texlabconfig.json'

M._servernames = {}

function M:servernames()
    self:read()
    return self._servernames
end

function M:add_servernames()
    local avaiable_servernames = {}
    self:read()
    for _, server in ipairs(vim.list_extend(self._servernames, { vim.v.servername })) do
        local ok = pcall(function()
            local socket = vim.fn.sockconnect('pipe', server)
            vim.fn.chanclose(socket)
        end)
        if ok then
            avaiable_servernames[#avaiable_servernames + 1] = server
        end
    end
    self._servernames = avaiable_servernames
    self:write()
end

function M:remove_servernames()
    for k, server in pairs(self:servernames()) do
        if server == vim.v.servername then
            table.remove(self._servernames, k)
            self:write()
            return
        end
    end
end

function M:write()
    local encode = json.encode(self._servernames)
    local file = io.open(self.fname, 'w')
    file:write(encode)
    file:close()
end

function M:read()
    local file = io.open(self.fname, 'r')
    if file then
        local data = file:read()
        file:close()
        local decode = json.decode(data)
        self._servernames = decode
    end
end

function M:autocmd_servernames()
    self:add_servernames()
    create_augroup('TeXLabCacheInit', { clear = true })

    --[[
    create_autocmd({ 'VimEnter' }, {
        callback = function()
            self:add_servernames()
        end,
        group = 'TeXLabCacheInit',
    })
    --]]

    create_autocmd({ 'VimLeavePre' }, {
        callback = function()
            self:remove_servernames()
        end,
        group = 'TeXLabCacheInit',
    })
end

return M
