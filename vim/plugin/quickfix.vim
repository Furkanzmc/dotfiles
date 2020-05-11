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

nmap <silent> <leader>qt :call quickfix#toggle()<CR>
command! ClearQuickFix :call setqflist([])
