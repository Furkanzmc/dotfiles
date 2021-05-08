" Based on https://github.com/mkitt/tabline.vim
" ${TAB_NUMBER}:[${FILE_NAME}] [${MODIFIED}]
function! tabline#config()
    let l:line = ''
    for tab_index in range(tabpagenr('$'))
        let l:tab_number = tab_index + 1
        let l:winnr = tabpagewinnr(l:tab_number)
        let l:buflist = tabpagebuflist(l:tab_number)
        let l:bufnr = l:buflist[l:winnr - 1]
        let l:bufname = bufname(l:bufnr)

        " Show the modified symbol if any of the buffers in the tab is modified.
        let l:modified_buf_count = 0
        let l:uniq_buflist = uniq(copy(l:buflist))
        for buf_index in l:uniq_buflist
            if getbufvar(buf_index, "&mod")
                let l:modified_buf_count += 1
            endif
        endfor

        " Add the tab number.
        let l:line .= '%' . l:tab_number . 'T'
        " Highlight the current tab.
        let l:line .= (l:tab_number == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
        let l:line .= ' ' . l:tab_number .':'
        let l:line .= (
                    \ l:bufname != '' ? fnamemodify(l:bufname, ':t') . ' '
                    \ : '[No Name] '
                    \ )

        if l:modified_buf_count > 0
            let l:line .= '[+' . l:modified_buf_count . '] '
        endif
    endfor

    let l:line .= '%#TabLineFill#'
    return l:line
endfunction
