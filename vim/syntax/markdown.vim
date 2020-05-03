if exists("b:markdown_conceal_set")
    finish
endif

call matchadd('Conceal', '^```[a-z]\+$', 10, -1, {'conceal':' '})
call matchadd('Conceal', '^```$', 10, -1, {'conceal':' '})

let b:markdown_conceal_set = v:true
