function! s:enable_highlight()
    if !exists(":SyntaxInclude")
        packadd SyntaxRange
    endif

    call SyntaxRange#Include('lua << EOF', 'EOF', 'lua', 'NonText')
endfunction

call s:enable_highlight()
