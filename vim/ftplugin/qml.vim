if !get(s:, "vimrc_qml_plugins_loaded", v:false)
    let s:vimrc_qml_plugins_loaded = v:true
endif

setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal errorformat+=file://%f:%l:\ %s%trror:\ %m,file://%f:%l:%c:\ %m,%f:%l:%c:\ %t%*[^:]:%m,%f:%l:\ %t%*[^:]:%m,%m\ (file://%f:%l),%m\ file\ %f\,\ line\ %l,file://%f:%l\ %m

command! -buffer -range RunQML :call qml#run()

inoremap <buffer> <c-s> <esc>Ion<esc>l~A: {<CR>}<ESC>O
inoremap <buffer> <c-d> <esc>Ion<esc>l~AChanged: {<CR>}<ESC>O
