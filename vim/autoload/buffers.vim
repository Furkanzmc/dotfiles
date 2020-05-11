function! buffers#close()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

function! buffers#set_indent(size)
    let &l:tabstop = a:size
    let &l:softtabstop = a:size
    let &l:shiftwidth = a:size
endfunction

" Buffer related code from https://stackoverflow.com/a/4867969
function! s:get_buflist()
    return filter(range(1, bufnr('$')), 'buflisted(v:val)')
endfunction

function! s:matching_buffers(pattern)
    return filter(s:get_buflist(), 'bufname(v:val) =~ a:pattern')
endfunction

function! buffers#wipe_matching(pattern)
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

    exec 'bw ' . join(l:matchList, ' ')

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

" Code taken from here: https://stackoverflow.com/a/6271254
function! buffers#get_visual_selection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return lines
    endif

    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return lines
endfunction

" Delete trailing white space on save, useful for some filetypes ;)
function! buffers#clean_extra_spaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction

" Code from https://www.vim.org/scripts/script.php?script_id=443
" Highlight trailing spaces, and tabs.
if !exists("g:vimrc_loaded_spacehi")
    let g:vimrc_loaded_spacehi = v:true

    if !exists("g:spacehi_tabcolor")
        let g:spacehi_tabcolor = "ctermfg=137 cterm=undercurl"
        let g:spacehi_tabcolor = g:spacehi_tabcolor . " guifg=#b28761 gui=undercurl"
    endif

    if !exists("g:spacehi_spacecolor")
        let g:spacehi_spacecolor = "ctermbg=196"
        let g:spacehi_spacecolor = g:spacehi_spacecolor . " guibg='#EB5A2D'"
    endif

    function! s:highlight_space()
        if exists("b:space_highlighted") && b:space_highlighted == v:true
            return
        endif

        if &filetype == "help" || &filetype == "qf"
            let b:space_highlighted = v:true
            return
        endif

        syntax match spacehiTab /\t/ containedin=ALL
        execute("highlight spacehiTab " . g:spacehi_tabcolor)

        syntax match spacehiTrailingSpace /\s\+$/ containedin=ALL
        execute("highlight spacehiTrailingSpace " . g:spacehi_spacecolor)
        let b:space_highlighted = v:true
    endfunction

    function! s:clear_highlight()
        if exists("b:space_highlighted") && b:space_highlighted == v:false
            return
        endif

        syntax match spacehiTab /\t/ containedin=ALL
        execute("highlight clear spacehiTab")

        syntax match spacehiTrailingSpace /\s\+$/ containedin=ALL
        execute("highlight clear spacehiTrailingSpace")

        let b:space_highlighted = v:false
    endfunction

    autocmd BufWinEnter * call s:highlight_space()
    autocmd InsertLeave * call s:highlight_space()
endif

function! s:cmd_line(mode, str)
    call feedkeys(a:mode . a:str)
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

function! buffers#mark_scratch()
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal buflisted
endfunction
