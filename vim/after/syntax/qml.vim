syn match qmlInlineType "\<[A-Z][a-z][_A-Za-z0-9]*\s*\(\(\.\|\ \)\w\+\)\@=\>"
syn match qmlImportQualifier "\(\<[A-Z][_A-Z0-9]*\s*\(\.\w\+\)\@=\>\|\<[A-Z][_A-Z0-9]*\s*$\)"
syn match qmlSignalHandler "\<on\w\+:\@=\>"

highlight link qmlInlineType qmlObjectLiteralType
highlight link qmlSignalHandler Function
highlight link qmlImportQualifier Label
