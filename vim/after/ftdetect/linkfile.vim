function s:open_link()
    let l:prompt = "Open it in the browser? (y/n): "
    let l:selection = input(l:prompt)
    if l:selection == "y"
        let l:filepath = expand("%")
        execute "!open " . l:filepath
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
