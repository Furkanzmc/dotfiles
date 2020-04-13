setlocal colorcolumn=120

autocmd BufRead *.html call buffers#set_indent(2)
autocmd BufNew *.html call buffers#set_indent(2)
