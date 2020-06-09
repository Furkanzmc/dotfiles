function! qml#run()
    if executable('qmlscene')
        if mode() == "v"
            let l:lines = buffers#get_visual_selection()
            let l:qml_file = tempname() . '.qml'

            call insert(l:lines, "import QtQuick 2.12")
            call insert(l:lines, "import QtQuick.Controls 2.4")
            call insert(l:lines, "import QtQuick.Layouts 1.3")
            call insert(l:lines, "import QtQuick.Window 2.12")
            call insert(l:lines, "import QtQuick.Dialogs 1.3")

            call writefile(l:lines, l:qml_file)
        else
            let l:qml_file = expand("%")
        endif

        execute 'NeomakeSh! pwsh -C "qmlscene ' . shellescape(l:qml_file) . '"'
    else
        echohl WarningMsg
        echo "Cannot find qmlscene in the path."
        echohl None
    endif
endfunction
