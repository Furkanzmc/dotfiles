if !get(s:, "todo_plugins_loaded", v:false)
    packadd SyntaxRange
    let s:todo_plugins_loaded = v:true
endif

setlocal colorcolumn=
setlocal cursorline

let b:match_ids = []
let s:done_conceal_pattern =  '\(^\ \{4,\}\[[xX]\]\|^\[[xX]\]\)\s.\+'

augroup todo_events
    autocmd!
    autocmd TextChanged <buffer> call <SID>update_conceal()
augroup END

command! -buffer HideDone call <SID>hide_done()
command! -buffer ShowDone call <SID>show_done()

if exists("s:todo_functions_loaded")
    finish
endif

let s:todo_functions_loaded = v:true
function! s:is_already_hidden(line_num)
    let l:index = 0
    for [line_number, match_id] in b:match_ids
        if line_number == a:line_num
            return l:index
        endif

        let l:index += 1
    endfor

    return -1
endfunction

function! s:hide_done()
    let l:line_count = line("$")
    let l:previous_concealed_line = -1
    for line_number in range(l:line_count)
        let l:line = getline(line_number)
        let l:existing_conceal_index = s:is_already_hidden(line_number)
        let l:is_done = !empty(matchstr(l:line, s:done_conceal_pattern))
        let l:is_subtask_done = !empty(matchstr(l:line, '^\ \{4,\}'))
        if l:is_done && l:existing_conceal_index > 0
            continue
        endif

        if l:is_done && l:existing_conceal_index == -1
            let l:match_id = matchaddpos(
                        \ 'Conceal', [line_number], 10, -1, {'conceal':' '})
            call add(b:match_ids, [line_number, l:match_id])
            let l:previous_concealed_line = line_number
        elseif l:previous_concealed_line == line_number - 1 && l:is_subtask_done && l:existing_conceal_index == -1
            let l:match_id = matchaddpos(
                        \ 'Conceal', [line_number], 10, -1, {'conceal':' '})
            call add(b:match_ids, [line_number, l:match_id])
            let l:previous_concealed_line = line_number
        elseif !l:is_done && !l:is_subtask_done && l:existing_conceal_index > -1
            call matchdelete(b:match_ids[l:existing_conceal_index][1])
            call remove(b:match_ids, l:existing_conceal_index)
        endif
    endfor
endfunction

function! s:show_done()
    for [line_number, match_id] in b:match_ids
        call matchdelete(match_id)
    endfor

    let b:match_ids = []
endfunction

function! s:update_conceal()
    if empty(b:match_ids)
        return
    endif

    call s:hide_done()
endfunction
