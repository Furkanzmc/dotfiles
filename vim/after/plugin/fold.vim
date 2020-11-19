augroup plugin_fold
    au!
    autocmd BufReadPost,BufNew,BufEnter * call fold#set_foldtext()
augroup END
