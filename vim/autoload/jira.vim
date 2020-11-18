function s:get_ticket_number()
    if !exists("g:vimrc_jira_base_url")
        echohl ErrorMsg
        echo "[jira] g:vimrc_jira_base_url is not set."
        echohl Normal
        return
    endif

    let l:branch_name = FugitiveHead()
    let l:match_list = matchlist(l:branch_name, "[A-Z]*-[0-9]*")
    if len(l:match_list)
        let l:ticket = l:match_list[0]
    else
        let l:ticket = ""
    endif

    if empty(l:ticket)
        echohl ErrorMsg
        echo "[jira] Cannot detect the ticket number."
        echohl Normal
    endif
endfunction

function jira#open_ticket(...)
    if a:0 == 0
        let l:ticket = s:get_ticket_number(a:000)
    else
        let l:ticket = a:1
    endif

    if empty(l:ticket)
        return
    endif

    if has("win32")
        execute "!explorer '" . g:vimrc_jira_base_url . "/browse/" . l:ticket . "'"
    else
        execute "!open '" . g:vimrc_jira_base_url . "/browse/" . l:ticket . "'"
    endif
endfunction

function jira#open_ticket_in_json(...)
    if a:0 == 0
        let l:ticket = s:get_ticket_number(a:000)
    else
        let l:ticket = a:1
    endif

    if empty(l:ticket)
        return
    endif

    if has("win32")
        execute "!explorer '" . g:vimrc_jira_base_url . "/rest/api/2/issue/" . l:ticket . "?expand=names'"
    else
        execute "!open '" . g:vimrc_jira_base_url . "/rest/api/2/issue/" . l:ticket . "?expand=names'"
    endif
endfunction
