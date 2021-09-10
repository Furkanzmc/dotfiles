if get(b:, "did_ftp", v:false)
    finish
endif

setlocal nonumber
setlocal norelativenumber
setlocal colorcolumn=
setlocal breakindentopt=shift:1

setlocal cursorline
execute "Setlocal trailingwhitespacehighlight=false"

vmap <buffer> <silent> D :<C-U>call quickfix#remove_lines(line("'<") - 1, line("'>") - 1)<CR>
nmap <buffer> <silent> D :call quickfix#remove_lines(line(".") - 1, line(".") - 1)<CR>
nmap <buffer> <silent> CC :ClearQuickFix<CR>
