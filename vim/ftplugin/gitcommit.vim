setlocal spell
setlocal colorcolumn=
setlocal signcolumn=no

setlocal nonumber
setlocal norelativenumber

" Append JIRA ticket number to commit message {{{

if (!exists("g:vimrc_active_jira_ticket") && !exists("b:ticket_number_appended")
            \ && exists("*FugitiveHead()"))
    let s:head = FugitiveHead()
    let s:matches = matchlist(s:head, "\[A-Z\]\\+-\[0-9\]\\+")
    if len(s:matches) > 0
        let g:vimrc_active_jira_ticket = s:matches[0]
    endif
endif

if exists("g:vimrc_active_jira_ticket") && !exists("b:ticket_number_appended")
    call append(line("^"), [g:vimrc_active_jira_ticket . ": "])
    execute ":normal gg$"

    let b:ticket_number_appended = v:true
endif

" }}}
