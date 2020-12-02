if get(b:, "vimrc_dirvish_did_dirvish", v:false)
    finish
endif

if get(g:, "vimrc_dirvish_virtual_text_enabled", v:false)
    let b:vimrc_dirvish_did_dirvish = v:true
    finish
endif

let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'
let b:vimrc_dirvish_initial_dir = expand("%")
let b:vimrc_dirvish_namespace = nvim_create_namespace(b:vimrc_dirvish_initial_dir)
let b:vimrc_dirvish_current_line = -1

if !exists("g:vimrc_dirvish_virtual_text_prefix")
    let g:vimrc_dirvish_virtual_text_prefix = "> "
endif

function s:get_info(path)
    let l:lines = []

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

    return l:lines
endfunction

function s:show_status(line1, line2)
    if a:line1 == a:line2 && b:vimrc_dirvish_current_line != a:line1
        call nvim_buf_clear_namespace(0, b:vimrc_dirvish_namespace, 0, -1)
    elseif a:line1 == a:line2 && b:vimrc_dirvish_current_line == a:line1
        return
    endif

    let l:lines = getline(a:line1, a:line2)

    let l:linenr = a:line1 - 1
    for line in l:lines
        let l:status_lines = [[g:vimrc_dirvish_virtual_text_prefix, "SpecialKey"]]

        call extend(l:status_lines, s:get_info(fnamemodify(line, ":.")))
        if len(l:status_lines) > 1
            call nvim_buf_set_virtual_text(0, b:vimrc_dirvish_namespace, l:linenr, l:status_lines, {})
        endif

        let l:linenr += 1
    endfor

    if a:line1 == a:line2
        let b:vimrc_dirvish_current_line = a:line1
    endif
endfunction

function s:toggle_conceal()
    if &l:conceallevel == 0
        setlocal conceallevel=2
    else
        setlocal conceallevel=0
    endif
endfunction

if executable("qlmanage")
    nmap <buffer> <silent> L :call jobstart(["qlmanage", "-p", getline(".")])<CR>
endif

nmap <buffer> <silent> S :call <SID>show_status(1, line("$"))<CR>
vmap <buffer> <silent> S :call <SID>show_status(line("'<"), line("'>"))<CR>
nmap <buffer> <silent> C :call <SID>toggle_conceal()<CR>

augroup dirvish_virtual_text
    au! * <buffer>
    autocmd CursorHold,BufEnter <buffer> call s:show_status(line("."), line("."))
    autocmd CursorMoved <buffer> if line(".") != b:vimrc_dirvish_current_line
                \ | call nvim_buf_clear_namespace(0, b:vimrc_dirvish_namespace, 0, -1)
                \ | endif
    autocmd BufLeave <buffer> call nvim_buf_clear_namespace(0, b:vimrc_dirvish_namespace, 0, -1)
augroup END

let b:vimrc_dirvish_did_dirvish = v:true
