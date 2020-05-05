setlocal signcolumn=no

autocmd BufWritePre *.txt :call buffers#clean_extra_spaces()
