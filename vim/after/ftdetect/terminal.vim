augroup ft_terminal
    au!
    autocmd BufNewFile,BufRead term://* setlocal filetype=terminal
    autocmd TermOpen * setlocal filetype=terminal
augroup END
