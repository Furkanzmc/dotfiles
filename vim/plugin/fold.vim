augroup plugin_fold
    au!
    autocmd BufReadPost * call fold#set_foldtext()
    autocmd BufNew * call fold#set_foldtext()
    autocmd BufEnter * call fold#set_foldtext()
augroup END
