setlocal foldmethod=indent

autocmd BufWritePre *.json :call buffers#clean_extra_spaces()
