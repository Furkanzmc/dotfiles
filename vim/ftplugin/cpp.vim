if !get(s:, "vimrc_cpp_plugins_loaded", v:false)
    packadd nvim-gdb
    packadd tagbar
    packadd vim-cpp-enhanced-highlight
    let s:vimrc_cpp_plugins_loaded = v:true
endif

setlocal foldmethod=indent
setlocal signcolumn=yes

" Override the default comment string from vim-commentary
setlocal commentstring=//%s

if get(g:, "swap_source_loaded", 0) == 0
    let g:swap_source_loaded = 1
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
            echo "Cannot file " . l:filename
        endtry

        setlocal path-=expand('%:h')
    endfunction
endif

nnoremap <silent> <buffer> <leader>gg :call cpp#swap_source_header()<CR>
