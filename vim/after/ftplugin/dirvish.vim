setlocal synmaxcol=256

if get(b:, "vimrc_dirvish_did_dirvish", v:false)
    finish
endif

if get(g:, "vimrc_dirvish_virtual_text_enabled", v:false)
    let b:vimrc_dirvish_did_dirvish = v:true
    finish
endif

let g:vimrc_dirvish_git_indicators = {
            \ 'M': '*',
            \ 'A': '+',
            \ 'D': '-',
            \ 'AD': '-',
            \ '??': '?',
            \ 'R': '<=',
            \ 'RM': '<=',
            \ 'AM': '<=',
            \ 'Unmerged': '═',
            \ '!!': '!',
            \ }

let s:sep = exists('+shellslash') && !&shellslash ? '\' : '/'
let b:vimrc_dirvish_initial_dir = expand("%")
let b:vimrc_dirvish_namespace = nvim_create_namespace(b:vimrc_dirvish_initial_dir)
let b:vimrc_dirvish_current_line = -1
let b:vimrc_dirvish_git_status = {}
let b:vimrc_dirvish_is_git_dir = v:null

if !exists("g:vimrc_dirvish_virtual_text_prefix")
    let g:vimrc_dirvish_virtual_text_prefix = "> "
endif

function! s:get_status(path) abort
    if b:vimrc_dirvish_is_git_dir == v:false
        return []
    endif

    let l:status = systemlist("git status --porcelain " . a:path)
    if len(l:status) ==? 0 || (len(l:status) ==? 1 && l:status[0] =~? '^fatal')
        let b:vimrc_dirvish_is_git_dir = !(len(l:status) ==? 1 && l:status[0] =~? '^fatal')
        return []
    endif

    let b:vimrc_dirvish_is_git_dir = v:true
    return l:status
endfunction

function s:get_git_info(path)
    let l:status = s:get_status(a:path)
    let l:indicators = {}
    for line in l:status
        let l:split = split(line, " ")
        call filter(l:split, "!empty(v:val)")

        let l:st = trim(substitute(trim(l:split[0]), ' \w\+.*', "", "g"))
        let l:fname = trim(l:split[1])
        if len(l:split) > 2
            let l:fname = trim(l:split[3])
        endif

        let l:folder = fnamemodify(l:fname, ":.:h")
        if match(l:folder, s:sep . "$") == -1
            let l:folder .= s:sep
        endif

        if len(l:split) > 2
            let b:vimrc_dirvish_git_status[fnamemodify(l:fname, ":.")] = 
                        \ g:vimrc_dirvish_git_indicators[l:st] . " " . fnamemodify(l:split[1], ":t")
        else
            let b:vimrc_dirvish_git_status[fnamemodify(l:fname, ":.")] = g:vimrc_dirvish_git_indicators[l:st]
        endif
        if !has_key(l:indicators, l:folder)
            let l:indicators[l:folder] = []
        endif

        call add(l:indicators[l:folder], g:vimrc_dirvish_git_indicators[l:st])
    endfor

    if isdirectory(a:path) && len(l:status) > 1
        let l:indicators[fnamemodify(a:path, ":.")] = [g:vimrc_dirvish_git_indicators["M"]]
    endif

    let l:folders = keys(l:indicators)
    for folder in l:folders
        call uniq(l:indicators[folder])
        if !has_key(b:vimrc_dirvish_git_status, folder)
            let b:vimrc_dirvish_git_status[folder] = join(l:indicators[folder], ",")
        endif
    endfor
endfunction

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

        if has_key(b:vimrc_dirvish_git_status, a:path)
            call extend(l:lines, [
                        \ [b:vimrc_dirvish_git_status[a:path], "Type"],
                        \ [" | ", "Operator"]])
        else
            let l:status_keys = keys(b:vimrc_dirvish_git_status)
            for key in l:status_keys
                let l:matched = match(substitute(key, s:sep, "", "g"),
                            \ '^' . substitute(a:path, s:sep, "", "g"))
                if l:matched != -1
                    call extend(l:lines, [
                                \ [b:vimrc_dirvish_git_status[key], "Type"],
                                \ [" | ", "Operator"]])
                    break
                endif
            endfor
        endif

        call extend(l:lines, [
                    \ [l:last_modified, "String"],
                    \ [" | ", "Operator"],
                    \ [l:size_text, "Number"]])
    endif

    return l:lines
endfunction

function s:show_status(line1, line2)
    let b:vimrc_dirvish_git_status = {}
    if a:line1 == a:line2 && b:vimrc_dirvish_current_line != a:line1
        call nvim_buf_clear_namespace(0, b:vimrc_dirvish_namespace, 0, -1)
    elseif a:line1 == a:line2 && b:vimrc_dirvish_current_line == a:line1
        return
    endif

    let l:lines = getline(a:line1, a:line2)
    if a:line1 != a:line2
        call s:get_git_info(expand("%:.:h"))
    endif

    let l:linenr = a:line1 - 1
    for line in l:lines
        let l:status_lines = [[g:vimrc_dirvish_virtual_text_prefix, "SpecialKey"]]
        if a:line1 == a:line2
            call s:get_git_info(line)
        endif

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

if executable("qlmanage")
    nmap <buffer> <silent> L :call jobstart(["qlmanage", "-p", getline(".")])<CR>
endif

nmap <buffer> <silent> S :call <SID>show_status(1, line("$"))<CR>
vmap <buffer> <silent> S :call <SID>show_status(line("'<"), line("'>"))<CR>

augroup dirvish_virtual_text
    au! * <buffer>
    autocmd BufLeave <buffer> let b:vimrc_dirvish_git_status = {}
    autocmd CursorHold,BufEnter <buffer> call s:show_status(line("."), line("."))
    autocmd CursorMoved <buffer> if line(".") != b:vimrc_dirvish_current_line
                \ | call nvim_buf_clear_namespace(0, b:vimrc_dirvish_namespace, 0, -1)
                \ | endif
    autocmd BufLeave <buffer> call nvim_buf_clear_namespace(0, b:vimrc_dirvish_namespace, 0, -1)
augroup END

let b:vimrc_dirvish_did_dirvish = v:true
