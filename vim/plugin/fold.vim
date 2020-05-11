autocmd BufReadPost * call fold#set_foldtext()
autocmd BufNew * call fold#set_foldtext()
autocmd BufEnter * call fold#set_foldtext()
