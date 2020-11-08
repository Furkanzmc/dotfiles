setlocal colorcolumn=120
setlocal suffixesadd=.html

call buffers#set_indent(2)

if get(s:, "html_plugin_loaded", v:false)
    finish
endif

augroup vimrc_html
    autocmd!
    autocmd BufRead *.html call buffers#set_indent(2)
    autocmd BufNew *.html call buffers#set_indent(2)
augroup END

let s:html_plugin_loaded = v:true
