if !get(g:, "vimrc_todo_plugins_loaded", v:false) && &loadplugins
    packadd SyntaxRange
    let g:vimrc_todo_plugins_loaded = v:true
endif

setlocal colorcolumn=
setlocal cursorline
setlocal foldmethod=expr
setlocal textwidth=1000

setlocal spell
setlocal foldexpr=todo#foldexpr(v:lnum)
setlocal foldtext=todo#foldtext()
setlocal expandtab

setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal commentstring=>\ %s

nmap <buffer> <silent> <leader>x :normal! mt0f]hrxA finished: =strftime("%d-%m-%Y %H:%M")<CR>`t<ESC>
nmap <buffer> <silent> <leader>i :normal! mt0f]hriA started: =strftime("%d-%m-%Y %H:%M")<CR>`t<ESC>
nmap <buffer> <silent> <leader>t :normal! mt0f]hr `t<CR>
nmap <buffer> <silent> <leader>d :normal! mt$a due: =strftime("%d-%m-%Y")<CR><ESC>`t

augroup todo_buf
    au! * <buffer>
    autocmd BufEnter <buffer> :call todo#enable_highlight()
augroup END
