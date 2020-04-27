" Initial config from: https://jip.dev/posts/a-simpler-vim-statusline/

" Always show the status line
set laststatus=2

function! statusline#is_fugitive_buffer(buffer_name)
    if has('win32')
        return match(a:buffer_name, 'fugitive:\\') != -1
    endif

    return match(a:buffer_name, 'fugitive://') != -1
endfunction

function! s:get_color(active, active_color, inactive_color)
    if a:active
        return '%#' . a:active_color . '#'
    else
        return '%#' . a:inactive_color . '#'
    endif
endfunction


" This function just outputs the content colored by the
" supplied colorgroup number, e.g. num = 2 -> User2
" it only colors the input if the window is the currently
" focused one
function! statusline#configure(winnum)
    let l:active = a:winnum == winnr()
    let g:vimrc_mode_map = {
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

    let l:status = ""

    " Mode sign {{{
    let l:excluded_file_types = ["help", "qf"]
    let l:status .= s:get_color(l:active, 'Visual', 'Comment')
    let l:handled = v:false
    let l:mode = mode()

    if l:active && &filetype == "fugitive" && l:mode != "c"
        let l:handled = v:true
        let l:status .= " GIT "
    elseif l:active && &filetype == "terminal" && l:mode != "c"
        if l:mode == "n"
            let l:handled = v:true
            let l:status .= " N.Terminal "
        elseif mode() == "t"
            let l:handled = v:true
            let l:status .= " Terminal "
        endif
    elseif l:active && &filetype == "dirvish" && l:mode != "c"
        let l:handled = v:true
        let l:status .= " DIRVISH "
    endif

    if l:mode != "c" && index(l:excluded_file_types, &filetype) != -1
        let l:handled = v:true
    endif

    if !l:handled && l:active
        let l:status .= " %{toupper(g:vimrc_mode_map[mode()])} "
    endif
    " }}}

    " Aysncrun Status {{{
    if exists("*asyncrun#status()") && asyncrun#status() == "run"
        let l:status .= s:get_color(l:active, 'SpecialKey', 'Comment')
        let l:status .= " [Running Job] "
    endif
    " }}}

    let l:status .= s:get_color(l:active, 'Error', 'ErrorMsg')
    let l:status .= '%h' " Help sign
    let l:status .= '%q' " Help sign
    let l:status .= '%w' " Preview sign

    " File path {{{
    if &filetype != "fugitive"
        let l:status .= s:get_color(l:active, 'Normal', 'Comment')
        let l:status .= " %{statusline#is_fugitive_buffer(expand('%')) ? expand('%:t') : expand('%')}"
    endif
    " }}}

    " Diff file signs {{{

    let l:status .= s:get_color(1, 'Type', 'Type')

    let l:buffer_git_tag = " %{"
    let l:buffer_git_tag .= "&diff && statusline#is_fugitive_buffer(expand('%')) ? '[head]' : "
    let l:buffer_git_tag .= "(&diff && !statusline#is_fugitive_buffer(expand('%')) ? '[local]' : '')"
    let l:buffer_git_tag .= "}"
    let l:status .= l:buffer_git_tag

    " }}}

    let l:status .= s:get_color(l:active, 'Identifier', 'Comment')
    let l:status .= '%r' " Readonly sign
    if &spell
        let l:status .= ' ☰'
    endif

    " Modified sign {{{

    let l:status .= s:get_color(l:active, 'SpecialChar', 'Comment')
    let l:status .= "%{&modified ? ' +' : ''}" " Modified sign

    if (l:active)
        " Code from: https://vi.stackexchange.com/a/14313
        let l:modified_buf_count = len(filter(getbufinfo(), 'v:val.changed == 1'))
        if (l:modified_buf_count > 0)
            let l:status .= ' [✎ ' . l:modified_buf_count . '] '
        endif
    endif

    " }}}

    let l:status .= '%=' " Switch to right side

    " Branch name {{{
    let l:status .= s:get_color(l:active, 'Visual', 'Comment')
    if exists("*FugitiveHead") && l:active
        let l:head = FugitiveHead()
        if empty(l:head) && exists('*FugitiveDetect') && !exists('b:git_dir')
            call FugitiveDetect(expand("%"))
            let l:head = fugitive#head()
        endif

        if !empty(l:head)
            let l:status .= ' ʯ ' . l:head . ' '
        endif
    endif
    " }}}

    return l:status
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
