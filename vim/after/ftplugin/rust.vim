if !get(s:, "vimrc_rust_plugins_loaded", v:false) && &loadplugins
    packadd tagbar
    packadd rust.vim
    let s:vimrc_rust_plugins_loaded = v:true
endif

setlocal signcolumn=yes
setlocal suffixesadd=.rs

if executable("rustfmt")
    setlocal formatprg=rustmft
endif

if executable("rustup")
    setlocal keywordprg=rustup\ doc
endif

let b:vimrc_rls_lsp_signs_enabled = 1
let b:vimrc_rls_lsp_location_list_enabled = 1
let b:vimrc_efm_lsp_signs_enabled = 1
let b:vimrc_efm_lsp_location_list_enabled = 1

let b:did_rust = v:true
