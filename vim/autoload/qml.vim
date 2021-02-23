let s:vimrc_qml_run_output_buffer = -1

function! qml#run(line1, line2)
    if executable('qmlscene')
        if a:line1 != a:line2
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

        if s:vimrc_qml_run_output_buffer == -1
            botright split new
        else
            let l:open_buf = luaeval("require'vimrc.utils'.find_open_window(" . s:vimrc_qml_run_output_buffer . ")")
            if l:open_buf.winnr != -1
                execute l:open_buf.winnr . " wincmd w"
            else
                botright split new
            endif
        endif

        execute 'FRun pwsh -NoProfile -NoLogo -NonInteractive -Command qmlscene ' . l:qml_file

        let s:vimrc_qml_run_output_buffer = bufnr()
    else
        echohl WarningMsg
        echo "Cannot find qmlscene in the path."
        echohl None
    endif
endfunction
