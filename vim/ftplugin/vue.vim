setlocal commentstring=//\ %s
setlocal colorcolumn=120

if get(s:, "vue_plugin_loaded", v:false)
    finish
endif

augroup vimrc_vue
    autocmd!
    autocmd BufRead *.vue call buffers#set_indent(2)
    autocmd BufNew *.vue call buffers#set_indent(2)
augroup END

let s:vue_plugin_loaded = v:true
