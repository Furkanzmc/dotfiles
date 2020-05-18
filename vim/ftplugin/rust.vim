if !get(s:, "vimrc_rust_plugins_loaded", v:false)
    packadd nvim-gdb
    packadd tagbar
    packadd rust.vim
    packadd ale
    let s:vimrc_rust_plugins_loaded = v:true
endif

