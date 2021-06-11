if get(b:, "did_qml", v:false)
    finish
endif

setlocal suffixesadd=.qml
setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal textwidth=100
setlocal colorcolumn=81,101

setlocal errorformat+=file://%f:%l:\ %s%trror:\ %m
setlocal errorformat+=file://%f:%l:%c:\ %m
setlocal errorformat=%f:%l:%c:\ %t%*[^:]:%m
setlocal errorformat=%f:%l:\ %t%*[^:]:%m
setlocal errorformat=%m\ (file://%f:%l)
setlocal errorformat=%m\ file\ %f\,\ line\ %l
setlocal errorformat=file://%f:%l\ %m

let b:vimrc_efm_lsp_signs_enabled = 1
let b:vimrc_efm_lsp_location_list_enabled = 1

command -buffer -range RunQML :call qml#run(<line1>, <line2>)

" Create signal handler.
abbreviate <silent> <buffer> s@ :<Esc>hxbion<Esc>l~$a<Space>{}<Esc>i<CR><Esc>O<C-R>=abbreviations#eat_char('\s')<CR>

" Create property change handler.
abbreviate <silent> <buffer> p@ :<Esc>hxbion<Esc>l~$iChanged<Right><Space>{}<Esc>i<CR><Esc>O<C-R>=abbreviations#eat_char('\s')<CR>

abbreviate <silent> <buffer> iqqc@ import QtQuick.Controls 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> iqq@ import QtQuick 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> iqql@ import QtQuick.Layouts 1.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> iqqw@ import QtQuick.Window 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> clog@ console.log("[<C-r>=expand("%:t") . "::" . line(".")<CR>::]")<Esc>F:a<C-R>=abbreviations#eat_char('\s')<CR>

let b:did_qml = v:true
