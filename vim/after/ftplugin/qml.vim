if !get(s:, "vimrc_qml_plugins_loaded", v:false)
    packadd neomake
    let s:vimrc_qml_plugins_loaded = v:true
endif

setlocal suffixesadd=.qml
setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal errorformat+=file://%f:%l:\ %s%trror:\ %m,file://%f:%l:%c:\ %m,%f:%l:%c:\ %t%*[^:]:%m,%f:%l:\ %t%*[^:]:%m,%m\ (file://%f:%l),%m\ file\ %f\,\ line\ %l,file://%f:%l\ %m

if get(b:, "qml_mappings_set", v:false)
    finish
endif

command -buffer -range RunQML :call qml#run(<line1>, <line2>)

inoremap <buffer> <c-l>s <ESC>bion<ESC>l~A: {<CR>}<ESC>O
inoremap <buffer> <c-l>d <ESC>bion<ESC>l~AChanged: {<CR>}<ESC>O
inoremap <buffer> <c-l>l console.log("[=expand("%:t")
inoremap <buffer> <c-l>u console.log("    ")F"i

abbreviate <buffer> iqqc import QtQuick.Controls 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> iqq import QtQuick 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> iqql import QtQuick.Layouts 1.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> iqqw import QtQuick.Window 2.<C-R>=abbreviations#eat_char('\s')<CR>

let b:qml_mappings_set = v:true