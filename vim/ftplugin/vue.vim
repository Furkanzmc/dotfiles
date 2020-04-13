setlocal commentstring=//\ %s
setlocal colorcolumn=120

autocmd BufRead *.vue call buffers#set_indent(2)
autocmd BufNew *.vue call buffers#set_indent(2)
