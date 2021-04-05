if !get(s:, "vimrc_rust_plugins_loaded", v:false) && &loadplugins
    packadd tagbar
    packadd rust.vim
    let s:vimrc_rust_plugins_loaded = v:true
endif

setlocal signcolumn=yes
setlocal suffixesadd=.rs
