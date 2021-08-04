function! quickfix#toggle()
    let tpbl = []
    call extend(tpbl, tabpagebuflist(tabpagenr()))

    let l:is_open = v:false
    for idx in tpbl
        if getbufvar(idx, "&buftype", "ERROR") == "quickfix"
            let l:is_open = v:true
            break
        endif
    endfor

    if l:is_open
        cclose
    else
        copen
    endif
endfunction

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
