if !get(s:, "vimrc_markdown_plugin_loaded", v:false)
    packadd vim-markdown-folding
    packadd SyntaxRange
endif

setlocal spell
setlocal colorcolumn=80,100
setlocal foldmethod=expr
setlocal conceallevel=2

if get(s:, "vimrc_markdown_plugin_loaded", v:false)
    finish
endif

command -buffer -range RunQML :call qml#run()

let s:vimrc_markdown_plugin_loaded = v:true
