if get(b:, "did_ftp", v:false)
    finish
endif

setlocal suffixesadd=.qml
setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal textwidth=100
setlocal includeexpr=includeexpr#find(v:fname\,[])
setlocal nocursorcolumn
setlocal formatexpr=

setlocal errorformat=file://%f:%l:%c:\ %m
setlocal errorformat+=file://%f:%l:\ %m
setlocal errorformat+=file://%f:%l\ %m
setlocal errorformat+=file://%f:%l:\ %m
setlocal errorformat+=file://%f:%l\ %m
setlocal errorformat+=file://%f:\ %m
setlocal errorformat+=qml:\ [%f::%l::%o]\ %m
setlocal errorformat+=%f:%l:%c:\ %t%*[^:]:%m
setlocal errorformat+=%f:%l:\ %t%*[^:]:%m
setlocal errorformat+=%m\ (file://%f:%l)
setlocal errorformat+=%m\ file\ %f\,\ line\ %l

if &loadplugins
    execute "Setlocal completion_timeout=50"
    execute "Setlocal tags_completion_enabled=false"
endif

let b:vimrc_null_ls_lsp_signs_enabled = 1
let b:vimrc_null_ls_lsp_virtual_text_enabled = 0

command -buffer -range RunQML :call qml#run(<line1>, <line2>)
command -buffer QMLEnableTracing :let $QML_IMPORT_TRACE=1
command -buffer QMLDisableTracing :let $QML_IMPORT_TRACE=""

abbreviate <silent> <buffer> tp@ topPadding:
abbreviate <silent> <buffer> rp@ rightPadding:
abbreviate <silent> <buffer> lp@ leftPadding:
abbreviate <silent> <buffer> bp@ bottomPadding:

abbreviate <silent> <buffer> tm@ topMargin:
abbreviate <silent> <buffer> rm@ rightMargin:
abbreviate <silent> <buffer> lm@ leftMargin:
abbreviate <silent> <buffer> bm@ bottomMargin:

abbreviate <silent> <buffer> trp@ transparent
abbreviate <silent> <buffer> oc@ Component.onCompleted: {<CR>

abbreviate <silent> <buffer> pr@ property TYPE NAME:<Esc>/\(TYPE\\|NAME\)<Enter>ciw<C-R>=abbreviations#eat_char('\s')<CR>

abbreviate <silent> <buffer> outline@ Rectangle {<CR>objectName: "outline"<CR>anchors.fill: parent<CR>color: "transparent"<CR>border {<CR>width: 1<CR>color: "red"<C-R>=abbreviations#eat_char('\s')<CR>

" Create signal handler.
abbreviate <silent> <buffer> s@ :<Esc>h"_xbion<Esc>l~$a<Space>{}<Esc>i<CR><Esc>O<C-R>=abbreviations#eat_char('\s')<CR>

" Create property change handler.
abbreviate <silent> <buffer> p@ :<Esc>h"_xbion<Esc>l~$iChanged<Right><Space>{}<Esc>i<CR><Esc>O<C-R>=abbreviations#eat_char('\s')<CR>

abbreviate <silent> <buffer> iqqc@ import QtQuick.Controls 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> iqq@ import QtQuick 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> iqql@ import QtQuick.Layouts 1.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> iqqw@ import QtQuick.Window 2.<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> clog@ console.log("[<C-r>=expand("%:t") . "::" . line(".")<CR>::]")<Esc>F:a<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> cl@ console.log("")<Esc>F(la<C-R>=abbreviations#eat_char('\s')<CR>
