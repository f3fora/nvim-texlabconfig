command! -nargs=* TexlabInverseSearch lua require('texlabconfig.cmd'):str_inverse_search_cmd(<q-args>)
