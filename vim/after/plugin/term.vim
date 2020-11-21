command! -nargs=? -complete=shellcmd Terminal
            \ :call term#open(v:false, <f-args>)
command! -nargs=? -complete=shellcmd TerminalFloating
            \ :call term#open(v:true, <f-args>)

command! -nargs=? -complete=shellcmd TerminalFloatingClose
            \ :call term#close(-1)

augroup term_plugin
    au!
    autocmd TermOpen * startinsert
augroup END
