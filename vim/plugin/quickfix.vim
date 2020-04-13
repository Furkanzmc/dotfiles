function! quickfix#toggle()
    let tpbl = []
    call extend(tpbl, tabpagebuflist(tabpagenr()))

    let l:quickFixOpen = v:false
    for idx in tpbl
        if getbufvar(idx, "&buftype", "ERROR") == "quickfix"
            let l:quickFixOpen = v:true
            break
        endif
    endfor

    if l:quickFixOpen
        cclose
    else
        copen
    endif
endfunction

nmap <silent> <leader>qt :call quickfix#toggle()<CR>
command! ClearQuickFix :call setqflist([])

