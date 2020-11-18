setlocal suffixesadd=.qml
setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal errorformat+=file://%f:%l:\ %s%trror:\ %m,file://%f:%l:%c:\ %m,%f:%l:%c:\ %t%*[^:]:%m,%f:%l:\ %t%*[^:]:%m,%m\ (file://%f:%l),%m\ file\ %f\,\ line\ %l,file://%f:%l\ %m

if get(b:, "did_qml", v:false)
    finish
endif

let b:vimrc_efm_lsp_signs_enabled = 1
let b:vimrc_efm_lsp_location_list_enabled = 1

command -buffer -range RunQML :call qml#run(<line1>, <line2>)

inoremap <buffer> <c-l>s <ESC>bion<ESC>l~A: {<CR>}<ESC>O
inoremap <buffer> <c-l>sh <ESC>bion<ESC>l~AChanged: {<CR>}<ESC>O

abbreviate <buffer> iqqc import QtQuick.Controls 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> iqq import QtQuick 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> iqql import QtQuick.Layouts 1.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> iqqw import QtQuick.Window 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> clog console.log("[=expand("%:t")<BS>::]")F:a<C-R>=abbreviations#eat_char('\s')<CR>

let b:did_qml = v:true
