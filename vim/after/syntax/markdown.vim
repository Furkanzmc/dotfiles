if exists("b:current_syntax")
    finish
endif

if !exists("b:markdown_conceal_set")
    call matchadd('Conceal', '^```[a-z]\+$', 10, -1, {'conceal':' '})
    call matchadd('Conceal', '^```$', 10, -1, {'conceal':' '})
endif

let b:markdown_conceal_set = v:true

let b:current_syntax = "markdown"
