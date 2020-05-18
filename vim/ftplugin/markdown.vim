if !get(s:, "vimrc_markdown_plugins_loaded", v:false)
    packadd vim-markdown-folding
    packadd SyntaxRange
    let s:vimrc_markdown_plugins_loaded = v:true
endif

setlocal spell
setlocal colorcolumn=80,100
setlocal signcolumn=no

command! -buffer -range RunQML :call qml#run()
