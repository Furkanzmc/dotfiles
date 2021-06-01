if exists("b:current_syntax_ext")
    finish
endif

call matchadd('Conceal', '^```[a-z]\+$', 10, -1, {'conceal':' '})
call matchadd('Conceal', '^```$', 10, -1, {'conceal':' '})

let b:current_syntax_ext = "markdown"
