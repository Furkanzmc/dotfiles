" Compare Functions {{{

function <SID>compare_modified_time(f1, f2)
    let l:mtime1 = getftime(a:f1)
    let l:mtime2 = getftime(a:f2)
    if l:mtime1 < l:mtime2
        return 1
    endif

    if l:mtime1 > l:mtime2
        return -1
    endif

    return 0
endfunction

function s:compare_length(a, b)
    let x = strlen(a:a)
    let y = strlen(a:b)
    return (x == y) ? 0 : (x < y) ? -1 : 1
endfunc

" }}}

function s:sort_modify_date(start_line, lines)
    let l:sorted = sort(a:lines, expand("<SID>") . "compare_modified_time")
    call setline(a:start_line, l:sorted)
endfunction

function s:sort_length(start_line, lines)
    let l:sorted = sort(a:lines, expand("<SID>") . "compare_length")
    call setline(a:start_line, l:sorted)
endfunction

function custom_sort#sort_command_completion(A,L,P)
    return ["-modified", "-length"]
endfunction

function custom_sort#sort(mode, start_line, end_line)
    if a:start_line == a:end_line
        let l:lines = getline(0, line('$'))
        let l:start_index = 1
    else
        let l:lines = getline(a:start_line, a:end_line)
        let l:start_index = a:start_line
    endif

    if a:mode == "-modified"
        if &filetype != "dirvish"
            echohl Error
            echo "[custom-sort] This mode is only available in dirvish buffer: " . a:mode
            echohl Normal
            return
        endif

        call s:sort_modify_date(l:start_index, l:lines)
    elseif a:mode == "-length"
        call s:sort_length(l:start_index, l:lines)
    else
        echohl Error
        echo "[custom-sort] Unsupported mode: " . a:mode
        echohl Normal
    endif
endfunction
