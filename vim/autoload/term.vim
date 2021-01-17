let s:term_floating_buffer = v:null
let s:term_count = 0

function! term#close(code) abort
    if a:code == 0
        let current_window = winnr()
        bdelete!
        if winnr() == current_window
            close
        endif
    elseif bufexists(s:term_floating_buffer)
        execute "bdelete! " . s:term_floating_buffer
    endif
endfunction

function! term#open(is_floating, ...)
    if a:is_floating
        if s:term_floating_buffer != v:null && bufexists(s:term_floating_buffer)
            execute "bdelete! " . s:term_floating_buffer
        endif

        let s:term_floating_buffer = windows#create_floating_window(0.8, 0.8)
    endif

    let l:program = ""
    if a:0 == 1
        let l:program = a:1
    else
        let l:program = get(g:, "vimrc_shell", &shell)
    endif

    if a:is_floating
        enew
        call termopen(l:program, {
                    \ "on_exit": {_, c -> term#close(c)},
                    \ })
    else
        enew
        call termopen(l:program)
    endif

    let s:term_count = s:term_count + 1
    execute ":file terminal-" . s:term_count
endfunction

function! term#open_named_list(names)
    for term_name in a:names
        call term#open(v:false)
        execute ":file " . term_name
    endfor
endfunction
