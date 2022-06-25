local vim = vim
local json = vim.json
local uv = vim.loop
local create_augroup = vim.api.nvim_create_augroup
local create_autocmd = vim.api.nvim_create_autocmd

local config = require('texlabconfig.config').get()
local utils = require('texlabconfig.utils')

local M = {}

M.fname = uv.fs_realpath(config.cache_root .. '/nvim-texlabconfig.json')
M.cache_filetypes = config.cache_filetypes
M.cache_activate = config.cache_activate
M.mode = config.file_permission_mode

M._servernames = {}

function M:servernames()
    self:read()
    return self._servernames
end

function M:add_servernames()
    local avaiable_servernames = {}
    self:read()
    for _, server in
        ipairs(
            -- unique servernames
            utils.list_unique(
                -- last nvim session is always first
                vim.list_extend({ vim.v.servername }, self._servernames)
            )
        )
    do
        local socket = uv.new_pipe(false)
        local ok, _ = pcall(uv.pipe_connect, socket, server)
        socket:close()
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
    local encode = json.encode({ servernames = self._servernames })
    local fd = assert(uv.fs_open(self.fname, 'w', M.mode))
    assert(uv.fs_write(fd, encode))
    assert(uv.fs_close(fd))
end

function M:read()
    if not utils.file_exists(self.fname, M.mode) then
        self:write()
        return
    end
    local fd = assert(uv.fs_open(self.fname, 'r', M.mode))
    local stat = assert(uv.fs_fstat(fd))
    local data = assert(uv.fs_read(fd, stat.size, 0))
    assert(uv.fs_close(fd))

    local decode = json.decode(data)
    self._servernames = decode.servernames
end

function M:autocmd_servernames()
    if not self.cache_activate then
        return
    end

    local augroup_id = create_augroup('TexlabCacheInit', { clear = true })
    create_autocmd({ 'FileType' }, {
        pattern = M.cache_filetypes,
        callback = function()
            self:add_servernames()
        end,
        group = augroup_id,
        desc = 'nvim-texlabconfig: add servernames to cache',
    })

    create_autocmd({ 'VimLeavePre' }, {
        callback = function()
            self:remove_servernames()
        end,
        group = augroup_id,
        desc = 'nvim-texlabconfig: remove servernames from cache',
    })
end

return M
