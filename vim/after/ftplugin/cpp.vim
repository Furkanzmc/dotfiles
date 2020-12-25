if !get(s:, "vimrc_cpp_plugins_loaded", v:false)
    packadd nvim-gdb
    packadd tagbar
    let s:vimrc_cpp_plugins_loaded = v:true
endif

setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal suffixesadd=.cpp,.h,.hxx,.cxx

if executable("clang-format")
    setlocal formatprg=clang-format
endif

let b:vimrc_clangd_lsp_signs_enabled = 1
let b:vimrc_clangd_lsp_location_list_enabled = 1
let b:vimrc_efm_lsp_signs_enabled = 1
let b:vimrc_efm_lsp_location_list_enabled = 1

" Override the default comment string from vim-commentary
setlocal commentstring=//%s
nnoremap <silent> <buffer> <nowait> <F4> :lua require"vimrc.plugins.cpp".swap_source_header()<CR>

" Abbreviations {{{

abbreviate <silent> <buffer> #i@ #include <><Left><C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> #i"@ #include ""<Left><C-R>=abbreviations#eat_char('\s')<CR>

" }}}

if get(b:, "did_cpp", v:false)
    finish
endif

let b:did_cpp = v:true
