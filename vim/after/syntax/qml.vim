if exists("b:current_syntax_ext")
    finish
endif

" syn match qmlObjectLiteralType "[A-Z][a-z][_A-Za-z0-9]*\s*\(\.\w\+\)\@="

let b:current_syntax_ext = "qml"
