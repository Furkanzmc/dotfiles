if get(b:, "did_lua", v:false)
    finish
endif

setlocal suffixesadd=.qml
setlocal foldmethod=indent
setlocal colorcolumn=81,101
setlocal textwidth=100

let b:did_lua = v:true
