" Based on https://github.com/mkitt/tabline.vim

" Rename tabs to show tab# and # of viewports
if (exists("g:vimrc_loaded_tabline") && g:vimrc_loaded_tabline) || &cp
  finish
endif

let g:vimrc_loaded_tabline = v:true

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
    let l:buf_modified = v:false
    for buf_index in l:buflist
        let l:buf_modified = getbufvar(buf_index, "&mod")
        if l:buf_modified
            break
        endif
    endfor

    " Add the tab number.
    let l:line .= '%' . l:tab_number . 'T'
    " Highlight the current tab.
    let l:line .= (l:tab_number == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let l:line .= ' ' . l:tab_number .':'
    let l:line .= (
                \ l:bufname != '' ? '['. fnamemodify(l:bufname, ':t') . '] '
                \ : '[No Name] '
                \ )

    if l:buf_modified
      let l:line .= '[+] '
    endif
  endfor

  let l:line .= '%#TabLineFill#'
  return l:line
endfunction

set tabline=%!tabline#config()
