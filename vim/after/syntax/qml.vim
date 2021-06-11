syn match qmlInlineType "\<[A-Z][a-z][_A-Za-z0-9]*\s*\(\.\w\+\)\@=\>"
syn match qmlSignalHandler "\<on\w\+:\@=\>"

highlight link qmlInlineType qmlObjectLiteralType
highlight link qmlSignalHandler Function
