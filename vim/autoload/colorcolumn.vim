function! colorcolumn#toggle(col)
    let columns = split(&colorcolumn, ",")
    if a:col == -1
        let columns = [columns[0]]
    else
        let found = index(columns, string(a:col))
        if found > -1
            call remove(columns, found)
        else
            call add(columns, a:col)
        endif
    endif

    execute "setlocal colorcolumn=" . join(columns, ",")
endfunction
