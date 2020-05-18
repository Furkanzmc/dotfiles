if !get(s:, "vimrc_qml_plugins_loaded", v:false)
    packadd ale
    let s:vimrc_qml_plugins_loaded = v:true
endif

setlocal foldmethod=indent

command! -buffer -range RunQML :call qml#run()

inoremap <buffer> <c-s> <esc>Ion<esc>l~A: {<CR>}<ESC>O
inoremap <buffer> <c-d> <esc>Ion<esc>l~AChanged: {<CR>}<ESC>O
