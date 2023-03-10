local setup = require('texlabconfig.config').setup

local M = {}

M.fn = require('texlabconfig.fn')
M.project_dir = require('texlabconfig.utils').project_dir

function M.setup(user_config)
    setup(user_config or {})
    local cache = require('texlabconfig.cache')
    cache:autocmd_servernames()
end

return M
