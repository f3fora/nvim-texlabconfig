local cache = require('texlabconfig.cache')

local config = require('texlabconfig.config')

local M = {}

function M.setup(user_config)
    config.setup(user_config or {})
    cache:autocmd_servernames()
end

return M
