if exists("b:current_syntax_ext")
    finish
endif

if !exists(":SyntaxInclude") && &loadplugins
    packadd SyntaxRange
endif

if &loadplugins
    call SyntaxRange#Include('lua << EOF', 'EOF', 'lua', 'NonText')
endif

let b:current_syntax_ext = "vim"
