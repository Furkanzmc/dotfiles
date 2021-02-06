augroup ft_todo
    au!
    autocmd BufNewFile,BufRead todo.txt setlocal filetype=todo
    autocmd BufNewFile,BufRead *.todo setlocal filetype=todo
augroup END
