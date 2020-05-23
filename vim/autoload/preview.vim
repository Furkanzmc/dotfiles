function! preview#show(title, lines, ...) abort
    let l:options = get(a:000, 0, {})

    silent execute "pedit " . a:title
    wincmd P

    setlocal modifiable
    setlocal noreadonly
    setlocal nobuflisted

    setlocal buftype=nofile
    setlocal bufhidden=wipe
    :%d

    call setline(1, a:lines)

    setlocal nomodifiable
    setlocal readonly

    let &l:filetype = get(l:options, 'filetype', 'vimrc-preview')
    if get(l:options, 'stay_here')
        wincmd p
    endif

    autocmd BufLeave <buffer> :q
endfunction
