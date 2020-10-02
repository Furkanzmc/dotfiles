function! s:enable_highlight()
    if !exists(":SyntaxInclude")
        packadd SyntaxRange
    endif

    call SyntaxRange#Include('lua << EOF', 'EOF', 'lua', 'NonText')
endfunction

augroup syn_vim
    au!
    autocmd BufEnter *.vim :call s:enable_highlight()
augroup END
