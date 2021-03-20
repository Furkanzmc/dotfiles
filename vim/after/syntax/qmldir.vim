if exists("b:current_syntax")
    finish
endif

syntax match QmlModule '^module' contains=NONE
syntax match QmlModuleName '[aA-zZ]\w\+\.[aA-zZ]\w\+$' contains=NONE
syntax match QmlFileName '[aA-zZ]\w\+\.qml$' contains=NONE
syntax match QmlComponentName '[aA-zZ]\w\+' contains=NONE
syntax match QmlComponentVersion '[0-9]\.[0-9]\+' contains=NONE
syntax match QmlComponentVersion '[0-9]\.[0-9]\+' contains=NONE
syntax match QmlSingleton '^singleton$' contains=NONE

highlight default link QmlModule Keyword
highlight default link QmlModuleName Structure
highlight default link QmlFileName Label
highlight default link QmlComponentName Tag
highlight default link QmlComponentVersion Number
highlight default link QmlSingleton Keyword

let b:current_syntax = "todo"
