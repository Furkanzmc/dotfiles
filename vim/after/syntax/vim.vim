if !exists(":SyntaxInclude") && &loadplugins
    packadd SyntaxRange
endif

if &loadplugins
    call SyntaxRange#Include('lua << EOF', 'EOF', 'lua', 'NonText')
endif
