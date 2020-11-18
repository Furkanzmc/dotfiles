if !get(s:, "vimrc_cpp_plugins_loaded", v:false)
    packadd nvim-gdb
    packadd tagbar
    packadd vim-cpp-enhanced-highlight
    let s:vimrc_cpp_plugins_loaded = v:true
endif

setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal suffixesadd=.cpp,.h,.hxx,.cxx

if executable("clang-format")
    setlocal formatprg=clang-format

    nnoremap <buffer> <silent> <nowait> gq msHmtgggqG`tzt`s
endif

" Override the default comment string from vim-commentary
setlocal commentstring=//%s
nnoremap <silent> <buffer> <nowait> <F4> :call cpp#swap_source_header()<CR>

" Abbreviations {{{

abbreviate <buffer> #i #include <><Left><C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <buffer> #i" #include ""<Left><C-R>=abbreviations#eat_char('\s')<CR>

inoremap <buffer> <c-l>fs <ESC>biset<ESC>l~A()<CR>{<CR>}<Up><CR><ESC>i    <Esc>mb2<Up>$i
inoremap <buffer> <c-l>fg <ESC>biget<ESC>l~A() const<CR>{<CR>}<Up><CR><ESC>i    

" }}}

if get(b:, "did_cpp", v:false)
    finish
endif

let b:did_cpp = v:true
