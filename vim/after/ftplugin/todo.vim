if get(b:, "did_ftp", v:false)
    finish
endif

if !get(g:, "vimrc_todo_plugins_loaded", v:false) && &loadplugins
    packadd SyntaxRange
    let g:vimrc_todo_plugins_loaded = v:true
endif

setlocal colorcolumn=201
setlocal cursorline
setlocal nocursorcolumn
setlocal foldmethod=marker
setlocal textwidth=200

setlocal signcolumn=no
setlocal spell
setlocal expandtab

setlocal showbreak=\ \ \ \ 
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal commentstring=>\ %s
setlocal comments=fb:*,fb:-,fb:+,n:>

" Since I'm using a single line for the todo items, this makes more sense.
nmap <buffer> j gj
nmap <buffer> k gk

nmap <buffer> <silent> <leader>x :normal! mt0f]hrxA finished: =strftime("%d-%m-%Y-%H:%M")<CR>`t<ESC>
nmap <buffer> <silent> <leader>i :normal! mt0f]hr@A started: =strftime("%d-%m-%Y-%H:%M")<CR>`t<ESC>
nmap <buffer> <silent> <leader>d :normal! mt$a -> =strftime("%d-%m-%Y")<CR><ESC>`t

augroup vimrc_todo_buf_fenced
    au! * <buffer>
    autocmd BufEnter <buffer> :lua require"vimrc.todo".enable_highlight()
    autocmd BufReadPre <buffer> :if exists("b:todo_fenced_languages_applied") | unlet b:todo_fenced_languages_applied | endif
augroup END
