let s:term_floating_buffer = v:null

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
    if !exists("*windows#create_floating_window")
        echoerr "windowing plugin is not loaded."
        return
    endif

    if a:is_floating
        if s:term_floating_buffer != v:null && bufexists(s:term_floating_buffer)
            execute "bdelete! " . s:term_floating_buffer
        endif

        let s:term_floating_buffer = windows#create_floating_window(0.8, 0.8)
    endif

    if a:0 == 1
        if a:is_floating
            call termopen(a:1, {"on_exit": {_, c -> term#close(c)}})
        else
            execute "e term://" . a:1
        endif
    else
        let l:term = get(g:, "vimrc_shell", &shell)
        if a:is_floating
            call termopen(l:term, {"on_exit": {_, c -> term#close(c)}})
        else
            execute "e term://" . l:term
        endif
    endif
endfunction

function! term#open_named_list(names)
    for term_name in a:names
        call term#open(v:false)
        execute ":file " . term_name
    endfor
endfunction

command! -nargs=? -complete=shellcmd Terminal
            \ :call term#open(v:false, <f-args>)
command! -nargs=? -complete=shellcmd TerminalFloating
            \ :call term#open(v:true, <f-args>)
command! LazyGit :call term#open(v:true, "lazygit")

command! -nargs=? -complete=shellcmd TerminalFloatingClose
            \ :call term#close(-1)

autocmd TermOpen * startinsert
