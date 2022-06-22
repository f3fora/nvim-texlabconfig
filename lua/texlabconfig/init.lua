local vim = vim
local uv = vim.loop

local create_user_command = vim.api.nvim_create_user_command

local cache = require('texlabconfig.cache')
local _config = require('texlabconfig.config')
local config = _config.get()

local M = {}

M.fn = require('texlabconfig.fn')
M.project_dir = require('texlabconfig.utils').project_dir

function M.setup(user_config)
    _config.setup(user_config or {})
    cache:autocmd_servernames()
end

return M
