setlocal foldmethod=indent

function! qml#run_selected()
    if executable('qmlscene')
        let lines = buffers#get_visual_selection()
        let tempfile = tempname() . '.qml'
        call insert(lines, "import QtQuick 2.10")
        call insert(lines, "import QtQuick.Controls 2.3")
        call insert(lines, "import QtQuick.Layouts 1.3")
        call insert(lines, "import QtQuick.Window 2.3")
        call writefile(lines, tempfile)
        execute 'AsyncRun qmlscene ' . shellescape(tempfile)
    else
        echohl WarningMsg
        echo "Cannot find qmlscene in the path."
        echohl None
    endif
endfunction

function! qml#run()
    if executable('qmlscene')
        execute 'AsyncRun qmlscene %'
    else
        echohl WarningMsg
        echo "Cannot find qmlscene in the path."
        echohl None
    endif
endfunction

command! -buffer RunQML :call qml#run()
command! -buffer -range RunQMLSelected :call qml#run_selected()

inoremap <buffer> <c-s> <esc>Ion<esc>l~A: {<CR>}<ESC>O
inoremap <buffer> <c-d> <esc>Ion<esc>l~AChanged: {<CR>}<ESC>O
