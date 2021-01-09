function s:open_link()
    let l:prompt = "Open it in the browser? (y/n/c): "
    let l:selection = input(l:prompt)
    let l:filepath = expand("%")
    if l:selection == "y"
        execute "!open " . l:filepath
        normal 
        execute "bdelete! " . l:filepath
    elseif l:selection == "c"
        normal 
        execute "bdelete! " . l:filepath
    else
        setlocal filetype=
    endif
endfunction

augroup ft_linkfile
    au!
    autocmd BufNewFile,BufRead http://* setlocal filetype=linkfile
    autocmd BufNewFile,BufRead https://* setlocal filetype=linkfile
    autocmd FileType linkfile call <SID>open_link()
augroup END
