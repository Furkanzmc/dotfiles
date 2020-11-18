setlocal foldmethod=indent
setlocal cursorline

if executable("jq")
    setlocal equalprg=jq
    setlocal formatprg=jq
    nnoremap <buffer> <silent> <nowait> gq msHmtgggqG`tzt`s
endif
