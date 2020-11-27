setlocal synmaxcol=256

if get(b:, "did_dirvish", v:false)
    finish
endif

if get(g:, "vimrc_dirvish_virtual_text_enabled", v:false)
    let b:did_dirvish = v:true
    finish
endif

let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'
let b:namespace = nvim_create_namespace(expand("%"))
let b:current_line = -1

if !exists("g:vimrc_dirvish_virtual_text_prefix")
    let g:vimrc_dirvish_virtual_text_prefix = "> "
endif

function s:get_info(linenr, path)
    if b:current_line != a:linenr
        call nvim_buf_clear_namespace(0, b:namespace, 0, -1)
    else
        return
    endif

    let l:lines = [[g:vimrc_dirvish_virtual_text_prefix, "SpecialKey"]]

    let l:size = getfsize(a:path) 
    if l:size > -1
        let l:last_modified = strftime('%Y-%m-%d.%H:%M:%S', getftime(a:path))
        if l:size < 1000000
            let l:size_text = printf('%.2f', l:size / 1000.0) . 'K'
        else
            let l:size_text = printf('%.2f', l:size / 1000000.0) . 'MB'
        endif

        call extend(l:lines, [
                    \ [l:last_modified, "String"],
                    \ [" | ", "Operator"],
                    \ [l:size_text, "Number"]])
    endif

    if len(l:lines) > 1
        call nvim_buf_set_virtual_text(0, b:namespace, a:linenr - 1, l:lines, {})
        let b:current_line = a:linenr
    endif
endfunction

if executable("qlmanage")
    nmap <buffer> <silent> L :call jobstart(["qlmanage", "-p", getline(".")])<CR>
endif

augroup dirvish_virtual_text
    au! * <buffer>
    autocmd CursorMoved,BufEnter <buffer> call s:get_info(line("."), getline("."))
augroup END

let b:did_dirvish = v:true
