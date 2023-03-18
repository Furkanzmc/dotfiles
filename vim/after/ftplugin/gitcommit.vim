if get(b:, "did_ftp", v:false)
    finish
endif

setlocal spell
setlocal colorcolumn=
setlocal nonumber
setlocal cursorline
setlocal nocursorcolumn
setlocal signcolumn=no
setlocal winbar=

setlocal norelativenumber

" Prepend JIRA ticket number to commit message {{{

if (!exists("g:vimrc_active_jira_ticket") && !exists("b:vimrc_ticket_number_appended")
            \ && exists("*FugitiveHead()"))
    let s:head = FugitiveHead()
    let s:matches = matchlist(s:head, "\[A-Z\]\\+-\[0-9\]\\+")
    if len(s:matches) > 0
        let b:vimrc_active_jira_ticket = s:matches[0]
    endif
endif

if (exists("g:vimrc_active_jira_ticket") || exists("b:vimrc_active_jira_ticket")) && !exists("b:vimrc_ticket_number_appended")
    let s:ticket_number = ""
    if exists("g:vimrc_active_jira_ticket") && !empty("g:vimrc_active_jira_ticket")
        let s:ticket_number = g:vimrc_active_jira_ticket
    else
        let s:ticket_number = b:vimrc_active_jira_ticket
    endif

    let s:already_exists = search(s:ticket_number, "n") != 0
    if !s:already_exists
        call append(line("^"), [s:ticket_number . ": "])
        execute ":normal gg$"
    endif

    let b:vimrc_ticket_number_appended = v:true
endif

" }}}
