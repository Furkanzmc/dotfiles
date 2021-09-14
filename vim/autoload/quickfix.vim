function! quickfix#remove_lines(line1, line2)
    let l:qfsize = getqflist({"size": 1}).size
    if a:line1 >= l:qfsize || a:line2 >= l:qfsize
        return
    elseif a:line1 < 0
        return
    endif

    let l:linenr = line(".")
    let l:qfall = getqflist()
    call remove(l:qfall, a:line1, a:line2)
    call setqflist(l:qfall, 'r')
    execute "normal " . l:linenr . "G"
endfunction
