if exists("b:current_syntax")
    finish
endif

if !exists(":SyntaxInclude") && &loadplugins
    packadd SyntaxRange
endif

call SyntaxRange#Include('lua << EOF', 'EOF', 'lua', 'NonText')

let b:current_syntax = "vim"
