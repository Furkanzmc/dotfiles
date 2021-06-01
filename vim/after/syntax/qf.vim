if exists("b:current_syntax_ext")
    finish
endif

syn match qfLineNr "[^|]*" contained contains=qfError,qfWarning,qfNote
syn match qfWarning "warning" contained
syn match qfNote "note" contained

let b:current_syntax_ext = "qf"
