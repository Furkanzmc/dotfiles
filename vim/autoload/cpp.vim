function! cpp#swap_source_header()
    let l:extension = expand('%:p:e')

    setlocal path+=expand('%:h')

    if l:extension == 'cpp'
        let l:filename = expand('%:t:r') . '.h'
    elseif l:extension =='h'
        let l:filename = expand('%:t:r') . '.cpp'
    endif

    try
        execute 'find ' . l:filename
    catch
        echohl ErrorMsg
        echo "[cpp]: Cannot file " . l:filename
        echohl Normal
    endtry

    setlocal path-=expand('%:h')
endfunction
