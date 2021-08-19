if get(b:, "vimrc_did_qf", v:false)
    finish
endif

setlocal nonumber
setlocal norelativenumber
setlocal colorcolumn=

setlocal cursorline
execute "Setlocal trailingwhitespacehighlight=false"

vmap <buffer> <silent> D :<C-U>call quickfix#remove_lines(line("'<") - 1, line("'>") - 1)<CR>
nmap <buffer> <silent> D :call quickfix#remove_lines(line(".") - 1, line(".") - 1)<CR>
nmap <buffer> <silent> CC :ClearQuickFix<CR>

let b:vimrc_did_qf = v:true
