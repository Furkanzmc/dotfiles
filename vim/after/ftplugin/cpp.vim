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
nnoremap <silent> <buffer> <nowait> <F4> :call <SID>swap_source_header()<CR>

" Abbreviations {{{

abbreviate <buffer> #i #include <><Left><C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> #i" #include ""<Left><C-R>=abbreviations#eat_char('\s')<CR>

inoremap <buffer> <c-l>fs <ESC>biset<ESC>l~A()<CR>{<CR>}<Up><CR><ESC>i    <Esc>mb2<Up>$i
inoremap <buffer> <c-l>fg <ESC>biget<ESC>l~A() const<CR>{<CR>}<Up><CR><ESC>i    

" }}}

if get(s:, "functions_loaded", v:false)
    finish
endif

function! s:swap_source_header()
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

let s:functions_loaded = v:true
