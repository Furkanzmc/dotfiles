setlocal foldmethod=indent
setlocal cursorline

if executable("jq")
    setlocal equalprg=jq
endif
