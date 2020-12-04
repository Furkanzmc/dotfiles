if !get(g:, "vimrc_todo_plugins_loaded", v:false)
    packadd SyntaxRange
    let g:vimrc_todo_plugins_loaded = v:true
endif

setlocal colorcolumn=
setlocal cursorline
setlocal foldmethod=expr
setlocal textwidth=1000

setlocal foldexpr=todo#foldexpr(v:lnum)
setlocal foldtext=todo#foldtext()

nmap <buffer> <silent> <leader>x :normal! mt0f]hrxA finished: =strftime("%d-%m-%Y %H:%M")<CR>`t<ESC>
nmap <buffer> <silent> <leader>i :normal! mt0f]hriA started: =strftime("%d-%m-%Y %H:%M")<CR>`t<ESC>
nmap <buffer> <silent> <leader>t :normal! mt0f]hr `t<CR>
nmap <buffer> <silent> <leader>d :normal! mt$a due: =strftime("%d-%m-%Y")<CR><ESC>`t

if exists("g:vimrc_todo_functions_loaded")
    finish
endif

let g:vimrc_todo_functions_loaded = v:true
let s:foldexpr_indent_blocks = v:false

function todo#foldexpr(line_number)
    let l:line = getline(a:line_number)
    if l:line =~ b:done_task_pattern
        let s:foldexpr_indent_blocks = v:true
        return 1
    elseif s:foldexpr_indent_blocks && l:line =~ '^\ \{4,\}'
        let l:match = matchstr(l:line, '^\ \{4,\}')
        return len(l:match) / 4 + 1
    else
        let s:foldexpr_indent_blocks = v:false
    endif

    return 0
endfunction

function todo#foldtext()
    let l:completed_task_count = 0
    let l:task_count = 0
    let l:line_count = 0
    let l:is_code_block = v:false

    for line_number in range(v:foldstart, v:foldend)
        let l:line = getline(line_number)
        if l:line =~ b:done_task_pattern
            let l:completed_task_count += 1
            let l:task_count += 1
        elseif l:line =~ b:task_pattern
            let l:task_count += 1
        elseif l:line =~ '^\ \{4,\}```\w\+$' && !l:is_code_block
            let l:is_code_block = v:true
        endif

        let l:line_count += 1
    endfor

    let l:foldchar = get(b:, 'foldchar', '>')
    let l:foldlevel = repeat(l:foldchar, v:foldlevel)

    if l:completed_task_count > 0
        return l:foldlevel . " Completed Tasks [" . l:completed_task_count . "/"
                    \ . l:task_count . "]"
    endif

    if l:is_code_block
        return l:foldlevel . " Codeblock [" . l:line_count . "]"
    endif

    return l:foldlevel . " [" . l:line_count . "]"
endfunction
