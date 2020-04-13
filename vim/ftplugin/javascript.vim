setlocal foldenable
setlocal nocindent

autocmd BufWritePre *.js :call buffers#clean_extra_spaces()
