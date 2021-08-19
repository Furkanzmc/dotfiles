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

function custom_sort#sort_command_completion(A,L,P)
    return ["-modified", "-length", "-uniq", "-folder-first"]
endfunction

function custom_sort#sort(mode, start_line, end_line)
    if a:mode == "-folder-first" && a:start_line == a:end_line
        execute "sort ,^.*[\/],"
        return
    elseif a:mode == "-folder-first"
        execute "'<,'>sort ,^.*[\/],"
        return
    end

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

        call sort(l:lines, expand("<SID>") . "compare_modified_time")
        call setline(l:start_index, l:lines)
    elseif a:mode == "-length"
        call sort(l:lines, expand("<SID>") . "compare_length")
        call setline(l:start_index, l:lines)
    elseif a:mode == "-uniq"
        call uniq(l:lines)
        call setline(l:start_index, l:lines)
    else
        echohl Error
        echo "[custom-sort] Unsupported mode: " . a:mode
        echohl Normal
    endif
endfunction
