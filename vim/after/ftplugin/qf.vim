setlocal nonumber
setlocal norelativenumber
setlocal colorcolumn=

setlocal cursorline

vmap <buffer> <silent> D :<C-U>call quickfix#remove_lines(line("'<") - 1, line("'>") - 1)<CR>
nmap <buffer> <silent> D :call quickfix#remove_lines(line(".") - 1, line(".") - 1)<CR>
