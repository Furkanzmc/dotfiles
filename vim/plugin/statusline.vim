" Initial config from: https://jip.dev/posts/a-simpler-vim-statusline/

" Always show the status line
set laststatus=2

function! statusline#is_fugitive_buffer(bufferName)
    if has('win32')
        return match(a:bufferName, 'fugitive:\\') != -1
    endif

    return match(a:bufferName, 'fugitive://') != -1
endfunction

function! s:get_color(active, activeColor, inactiveColor)
    if a:active
        return '%#' . a:activeColor . '#'
    else
        return '%#' . a:inactiveColor . '#'
    endif
endfunction


" This function just outputs the content colored by the
" supplied colorgroup number, e.g. num = 2 -> User2
" it only colors the input if the window is the currently
" focused one
function! statusline#configure(winnum)
    let active = a:winnum == winnr()
    let g:currentmode = {
                \ 'n'      : 'Normal',
                \ 'no'     : 'N.Operator Pending ',
                \ 'v'      : 'V',
                \ 'V'      : 'V.Line',
                \ '' : 'V.Block',
                \ 's'      : 'Select',
                \ 'S'      : 'S.Line',
                \ '\<C-S>' : 'S.Block',
                \ 'i'      : 'Insert',
                \ 'R'      : 'Replace',
                \ 'Rv'     : 'V.Replace',
                \ 'c'      : 'Command',
                \ 'cv'     : 'Vim Ex',
                \ 'ce'     : 'Ex',
                \ 'r'      : 'Prompt',
                \ 'rm'     : 'More',
                \ 'r?'     : 'Confirm',
                \ '!'      : 'Shell',
                \ 't'      : 'Terminal'
                \}

    let stat = ""

    " Mode sign {{{
    let l:excluded_file_types = ["help", "qf", "terminal", "dirvish"]
    let stat .= s:get_color(active, 'Visual', 'Comment')
    if active && &filetype == "fugitive"
        let stat .= " GIT "
    elseif active && &filetype == "terminal"
        if mode() == "n"
            let stat .= " N.Terminal "
        else
            let stat .= " Terminal "
        endif
    elseif active && index(l:excluded_file_types, &filetype) == -1
        let stat .= " %{toupper(g:currentmode[mode()])} "
    elseif active && &filetype == "dirvish"
        let stat .= " DIRVISH "
    endif
    " }}}

    let stat .= s:get_color(active, 'Error', 'ErrorMsg')
    let stat .= '%h' " Help sign
    let stat .= '%q' " Help sign
    let stat .= '%w' " Preview sign

    " File path {{{
    if &filetype != "fugitive"
        let stat .= s:get_color(active, 'Normal', 'Comment')
        let stat .= " %{statusline#is_fugitive_buffer(expand('%')) ? expand('%:t') : expand('%')}"
    endif
    " }}}

    " Diff file signs {{{

    let stat .= s:get_color(1, 'Type', 'Type')
    let bufferGitTag = " %{"
    let bufferGitTag .= "&diff && statusline#is_fugitive_buffer(expand('%')) ? '[head]' : "
    let bufferGitTag .= "(&diff && !statusline#is_fugitive_buffer(expand('%')) ? '[local]' : '')"
    let bufferGitTag .= "}"
    let stat .= bufferGitTag

    " }}}

    let stat .= s:get_color(active, 'Identifier', 'Comment')
    let stat .= '%r' " Readonly sign
    if &spell
        let stat .= ' ☰'
    endif

    " Modified sign {{{

    let stat .= s:get_color(active, 'SpecialChar', 'Comment')
    let stat .= "%{&modified ? ' +' : ''}" " Modified sign

    if (active)
        " Code from: https://vi.stackexchange.com/a/14313
        let modifiedBufferCount = len(filter(getbufinfo(), 'v:val.changed == 1'))
        if (modifiedBufferCount > 0)
            let stat .= ' [✎ ' . modifiedBufferCount . '] '
        endif
    endif

    " }}}

    let stat .= '%=' " Switch to right side

    " Branch name {{{
    let stat .= s:get_color(active, 'Visual', 'Comment')
    if exists("*FugitiveHead") && active
        let head = FugitiveHead()
        if empty(head) && exists('*FugitiveDetect') && !exists('b:git_dir')
            call FugitiveDetect(expand("%"))
            let head = fugitive#head()
        endif

        if !empty(head)
            let stat .= ' ʯ ' . head . ' '
        endif
    endif
    " }}}

    return stat
endfunction

function! s:refresh_status()
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!statusline#configure(' . nr . ')')
    endfor
endfunction

augroup Status
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * call <SID>refresh_status()
augroup END

" }}}
