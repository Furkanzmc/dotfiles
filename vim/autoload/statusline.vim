" Initial config from: https://jip.dev/posts/a-simpler-vim-statusline/

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

function! s:lsp_daignostic(active) abort
    if !exists("*neomake#statusline#LoclistCounts") || !a:active
        return ""
    endif

    let l:dict = neomake#statusline#LoclistCounts()
    let l:errors = get(l:dict,'E', 0)
    let l:warnings = get(l:dict, 'W', 0)

    let l:status = ""
    if l:errors > 0
        let l:status .= s:get_color(a:active, 'Identifier', 'Identifier')
        let l:status .= " E: " . l:errors . " "
    endif

    if l:warnings > 0
        let l:status .= s:get_color(a:active, 'Type', 'Type')
        let l:status .= " W: " . l:warnings . " "
    endif

    return l:status
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
            let l:status .= " N.TERMINAL "
        elseif l:mode == "t"
            let l:handled = v:true
            let l:status .= " TERMINAL "
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

    if l:active
        " FIXME: nvim-lsp somtimes stops working. This is a convenient way to
        " see If LSP is working or not.
        try
            let l:is_lsp_active = luaeval("vim.inspect(vim.lsp.buf_get_clients())") != "{}"
        catch
            let l:is_lsp_active = v:false
        endtry

        if l:is_lsp_active
            let l:status .= s:get_color(l:active, 'SpecialKey', 'Comment')
            let l:status .= " ⚙ "
        endif
    endif

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

    " LSP Diagnostic {{{

    let l:diagnostic_enabled_types = get(
                \ g:, "vimrc_statusline_lsp_diagnostics", ["python", "qml", "cpp"])

    if index(l:diagnostic_enabled_types, &filetype) >= 0
        let l:status .= s:lsp_daignostic(l:active)
    endif

    " }}}

    " HTTP Request Status {{{

    if exists(":SendHttpRequest") > 0
        let l:http_in_progress = get(g:, "nvim_http_request_in_progress", v:false)
        if l:http_in_progress
            let l:status .= s:get_color(l:active, 'Special', 'Comment')
            let l:status .= " [Http] "
        endif
    endif

    " }}}


    " Branch name {{{

    let l:status .= s:get_color(l:active, 'Visual', 'Comment')
    if exists("*FugitiveHead") && l:active
        let l:head = FugitiveHead()
        if empty(l:head) && exists('*FugitiveDetect') && !exists('b:git_dir')
            call FugitiveDetect(expand("%"))
            let l:head = fugitive#head()
        endif

        if !empty(l:head)
            let l:status .= '  ' . l:head . ' '
        endif
    endif

    " }}}

    return l:status
endfunction

" }}}
