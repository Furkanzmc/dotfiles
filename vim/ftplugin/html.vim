setlocal colorcolumn=120
call buffers#set_indent(2)

autocmd BufRead *.html call buffers#set_indent(2)
autocmd BufNew *.html call buffers#set_indent(2)
