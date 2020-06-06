function! python#get_pylint_error_message(error_code)
    if !exists('~/.dotfiles/vim/temp_dirs/tmp_files/pylint_messages.txt')
        call system(
                    \ 'pylint --list-msgs > ' .
                    \ '~/.dotfiles/vim/temp_dirs/tmp_files/pylint_messages.txt')
    endif

    " 50 is an arbitrary context so I can show the description of the pylint
    " code as well. There's better ways of doing it, just feeling lazy now.
    let l:output_lines = systemlist(
                \ "rg -F '("
                \ . a:error_code . ")'"
                \ . " ~/.dotfiles/vim/temp_dirs/tmp_files/pylint_messages.txt"
                \ . " --after-context 20")
    if len(l:output_lines) == 0
        echohl Error
        echo "No pylint message for " . a:error_code
        echohl Normal
        return
    endif

    let l:message = [l:output_lines[0]]
    let l:output_lines = l:output_lines[1:]
    for line in l:output_lines
        if line[0] == ":"
            break
        else
            call add(l:message, line)
        endif
    endfor

    if len(l:message)
        call preview#show("Pylint Message [" . a:error_code . "]", l:message)
    endif
endfunction
