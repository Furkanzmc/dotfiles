function! term#close(code) abort
    if a:code == 0
        let l:current_window = winnr()
        bdelete!
        if winnr() == l:current_window
            close
        endif
    endif
endfunction

function! term#open(...) abort
    if a:0 == 1
        let l:program = a:1
    else
        let l:program = luaeval("require'options'.get_option_value('shell')")
    endif

    enew
    call termopen(l:program)
endfunction

function! term#open_named_list(names) abort
    for term_name in a:names
        call term#open(v:false)
        execute ":file " . term_name
    endfor
endfunction
