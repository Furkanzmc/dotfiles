if !get(s:, "todo_plugins_loaded", v:false)
    packadd SyntaxRange
    let s:todo_plugins_loaded = v:true
endif

setlocal colorcolumn=
setlocal cursorline
setlocal foldmethod=expr
setlocal foldexpr=todo#foldexpr(v:lnum)
setlocal foldtext=todo#foldtext()

nmap <buffer> <silent> <leader>x :normal! mt0f]hrx`t<CR>
nmap <buffer> <silent> <leader>i :normal! mt0f]hri`t<CR>
nmap <buffer> <silent> <leader>t :normal! mt0f]hr `t<CR>

if exists("s:todo_functions_loaded")
    finish
endif

let s:todo_functions_loaded = v:true

function todo#foldexpr(line_number)
    let l:line = getline(a:line_number)
    if l:line =~ b:done_task_pattern
        return 1
    elseif l:line =~ '^\ \{4,\}'
        let l:match = matchstr(l:line, '^\ \{4,\}')
        return len(l:match) / 4
    endif

    return 0
endfunction

function todo#foldtext()
    let l:completed_tasks = 0
    for line_number in range(v:foldstart, v:foldend)
        let l:line = getline(line_number)
        if l:line =~ b:done_task_pattern
            let l:completed_tasks += 1
        endif
    endfor

    let l:foldchar = get(b:, 'foldchar', '>')
    return l:foldchar . " Completed Tasks [" . l:completed_tasks . "]"
endfunction
