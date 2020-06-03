if !get(s:, "vimrc_todo_plugins_loaded", v:false)
    packadd SyntaxRange
    let s:vimrc_todo_plugins_loaded = v:true
endif

setlocal colorcolumn=
setlocal cursorline
