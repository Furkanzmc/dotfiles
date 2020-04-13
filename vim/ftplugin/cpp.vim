setlocal foldmethod=indent

" Override the default comment string from vim-commentary
setlocal commentstring=//%s
setlocal formatexpr=LanguageClient#textDocument_rangeFormatting_sync()

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

if get(g:, "vimrc_cpp_remove_whitespace", v:true)
    autocmd BufWritePre *.h,*.cpp :call buffers#clean_extra_spaces()
endif
