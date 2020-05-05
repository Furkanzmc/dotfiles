setlocal foldmethod=indent
setlocal signcolumn=no

autocmd BufWritePre *.json :call buffers#clean_extra_spaces()
