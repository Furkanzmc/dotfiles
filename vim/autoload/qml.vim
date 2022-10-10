let s:vimrc_qml_run_output_buffer = -1

function! qml#run(line1, line2)
    let l:executable = ""

    if executable("qml")
        let l:executable = "qml"
    elseif executable('qmlscene')
        let l:executable = "qmlscene"
    else
        echohl ErrorMsg
        echo "[qml] qml or qmlscene must be executable."
        echohl Normal
    endif

    if a:line1 != a:line2
        let l:lines = luaeval("require'vimrc.buffers'.get_last_selection(vim.api.nvim_get_current_buf())")
        let l:qml_file = tempname() . '.qml'

        call insert(l:lines, "import QtQuick 2.15")
        call insert(l:lines, "import QtQuick.Controls 2.15")
        call insert(l:lines, "import QtQuick.Layouts 1.5")
        call insert(l:lines, "import QtQuick.Window 2.15")

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

    execute 'FRun pwsh -NoProfile -NoLogo -NonInteractive -Command ' . l:executable . ' ' . l:qml_file

    let s:vimrc_qml_run_output_buffer = bufnr()
endfunction
