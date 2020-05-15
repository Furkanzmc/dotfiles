function! s:refresh_status()
    for nr in range(1, winnr('$'))
        call setwinvar(
                    \ nr,
                    \ '&statusline',
                    \ '%!statusline#configure(' . nr . ')')
    endfor
endfunction

augroup Status
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * call <SID>refresh_status()
    autocmd User NvimHttpRequestStarted call <SID>refresh_status()
    autocmd User NvimHttpRequestEnded call <SID>refresh_status()
augroup END

