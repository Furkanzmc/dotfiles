" Buffer related code from https://stackoverflow.com/a/4867969
function! s:get_buflist()
    return filter(range(1, bufnr('$')), 'buflisted(v:val)')
endfunction

function! s:matching_buffers(pattern)
    return filter(s:get_buflist(), 'bufname(v:val) =~ a:pattern')
endfunction

function! s:cmd_line(mode, str)
    call feedkeys(a:mode . a:str)
endfunction

function! buffers#wipe_matching(pattern, bang)
    if a:pattern == "*"
        let l:matchList = s:get_buflist()
    else
        let l:matchList = s:matching_buffers(a:pattern)
    endif

    let l:count = len(l:matchList)
    if l:count < 1
        echo 'No buffers found matching pattern ' . a:pattern
        return
    endif

    if l:count == 1
        let l:suffix = ''
    else
        let l:suffix = 's'
    endif

    if a:bang == "!"
        exec 'bw! ' . join(l:matchList, ' ')
    else
        exec 'bw ' . join(l:matchList, ' ')
    endif

    echo 'Wiped ' . l:count . ' buffer' . l:suffix . '.'
endfunction

" Delete all hidden buffers
" From https://github.com/zenbro/dotfiles/blob/master/.nvimrc
function! buffers#delete_hidden()
    let tpbl = []
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    let l:matchList = filter(
                \ range(1, bufnr('$')),
                \ 'bufexists(v:val) && index(tpbl, v:val)==-1')
    let l:count = len(l:matchList)
    for buf in l:matchList
        silent execute 'bwipeout' buf
    endfor

    if l:count > 0
        echo 'Closed ' . l:count . ' hidden buffers.'
    else
        echo 'No hidden buffer present.'
    endif
endfunction

function! buffers#wipe_nonexisting_files()
    let l:matchList = filter(s:get_buflist(),
                \ '!file_readable(bufname(v:val))')

    let l:count = len(l:matchList)
    if l:count < 1
        return
    endif

    if l:count == 1
        let l:suffix = ''
    else
        let l:suffix = 's'
    endif

    exec 'bw! ' . join(l:matchList, ' ')

    echo 'Wiped ' . l:count . ' buffer' . l:suffix . '.'
endfunction

" Code taken from here: https://stackoverflow.com/a/6271254
function! buffers#get_visual_selection()
    let [l:line_start, l:column_start] = getpos("'<")[1:2]
    let [l:line_end, l:column_end] = getpos("'>")[1:2]
    let l:lines = getline(l:line_start, l:line_end)
    if len(l:lines) == 0
        return l:lines
    endif

    let l:lines[-1] = l:lines[-1][: l:column_end - (&selection == 'inclusive' ? 1 : 2)]
    let l:lines[0] = l:lines[0][l:column_start - 1:]
    return l:lines
endfunction

function! buffers#visual_selection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'search'
        call s:cmd_line('/', l:pattern)
    elseif a:direction == 'replace'
        call s:cmd_line(':', "%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
