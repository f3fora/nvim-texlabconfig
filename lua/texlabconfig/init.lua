local vim = vim

local cache = require('texlabconfig.cache')
local config = require('texlabconfig.config')
local cmd = require('texlabconfig.cmd')

local M = {}

function M.setup(user_config)
    config.setup(user_config or {})
    cache:autocmd_servernames()

    vim.api.nvim_create_user_command('TexlabInverseSearch', function(args_tbl)
        cmd:str_inverse_search_cmd(args_tbl.args)
    end, {
        nargs = '+',
    })
end

return M
