if exists("b:current_syntax")
    finish
endif

syntax match HflDate '\d\{2,4\}-\d\{2\}-\d\{4\}\|\d\{4\}-\d\{2,4\}-\d\{2\}' contains=NONE
syntax match HflContext '\(^\|\W\)@[^[:blank:]]\+' contains=NONE

highlight default link HflDate Number
highlight default link HflContext Label

let b:current_syntax = "hfl"
