if !get(s:, "vimrc_cpp_plugins_loaded", v:false) && &loadplugins
    packadd! tagbar
    let s:vimrc_cpp_plugins_loaded = v:true
endif

setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal suffixesadd=.c,.h

let b:vimrc_clangd_lsp_signs_enabled = 1
let b:vimrc_clangd_lsp_location_list_enabled = 1
let b:vimrc_ccls_lsp_signs_enabled = 1
let b:vimrc_ccls_lsp_location_list_enabled = 1
let b:vimrc_efm_lsp_signs_enabled = 1
let b:vimrc_efm_lsp_location_list_enabled = 1

" Override the default comment string from vim-commentary
setlocal commentstring=//%s
nnoremap <silent> <buffer> <nowait> <leader>ch :lua require"vimrc.cpp".swap_source_header()<CR>

" Abbreviations {{{

abbreviate <silent> <buffer> #i@ #include <><Left><C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> #i"@ #include ""<Left><C-R>=abbreviations#eat_char('\s')<CR>

" }}}

if get(b:, "did_c", v:false)
    finish
endif

let b:did_c = v:true
