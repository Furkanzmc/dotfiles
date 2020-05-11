setlocal foldmethod=indent
setlocal signcolumn=no
setlocal cursorline

autocmd BufWritePre *.json :call buffers#clean_extra_spaces()
