function! python#get_pylint_error_message(error_code)
    if !exists('~/.dotfiles/vim/temp_dirs/tmp_files/pylint_messages.txt')
        call system(
                    \ 'pylint --list-msgs > ' .
                    \ '~/.dotfiles/vim/temp_dirs/tmp_files/pylint_messages.txt')
    endif

    let l:message = trim(system(
                \ "cat ~/.dotfiles/vim/temp_dirs/tmp_files/pylint_messages.txt | rg -F '("
                \ . a:error_code . ")'"))
    if len(l:message)
        call preview#show("Pylint Message [" . a:error_code . "]", [l:message])
    else
        echohl Error
        echo "No pylint message for " . a:error_code
        echohl Normal
    endif
endfunction
