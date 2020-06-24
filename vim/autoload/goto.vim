" Initial code belongs to Rudy Wortel

function! s:grep_output()
    "C:/Studio/main/Jamrules.jam:134: dummy text "this/is/a/file:123: parse this!
    let status = v:false
    let l:match_list = matchlist(
                \ s:file_line, '^\([a-zA-Z]\):\([^:]*\):\([0-9]*\):')
    if len(l:match_list)
        let s:cmd = "edit +" . l:match_list[3] . " "
                    \ . l:match_list[1] . ":" . l:match_list[2]
        let status = v:true
    else
        let l:match_list = matchlist( s:file_line, '^\([^:]*\):\([0-9]*\):' )
        if len(l:match_list)
            let s:cmd = "edit +" . l:match_list[2] . " " . l:match_list[1]
            let status = v:true
        endif
    endif

    return status
endfunction

function! s:msvc_error()
    "c:\main\build\Release\units\Foundation\include\MFn.h(90) : error C2061: syntax error : identifier 'kBase'
    let status = v:false
    let l:match_list = matchlist(
                \ s:file_line, '^ *\([^(]*\)(\([0-9]*\)) : \([^ ]*\)')
    if len(l:match_list)
        let type = l:match_list[3]
        if type ==? "error" || type ==? "warning"
                    \ || type ==? "fatal" || type ==? "see" || type ==? "while"
            let s:cmd = "edit +" . l:match_list[2] . " " . l:match_list[1]
            let status = v:true
        endif
    endif

    return status
endfunction

function! s:include_statement()
    let status = v:false
    let l:match_list = matchlist(
                \ s:file_line, '^#[     ]*include[     ]*["<]\([^">]*\)' )

    if len(l:match_list)
        let s:cmd = "tag " . l:match_list[1]
        let status = v:true
    endif

    return status
endfunction

function! s:include_from()
    let status = v:false
    let l:match_list = matchlist(
                \ s:file_line, '^In file included from \([^:>]*\):\([0-9]*\)')

    if len(l:match_list)
        let s:cmd = "edit +" . l:match_list[2] . " " . l:match_list[1]
        let status = v:true
    endif

    return status
endfunction

function! s:msvc_stack()
    let status = v:false
    let l:match_list = matchlist(
                \ s:file_line, '.*\.dll!\([^(]*\).* Line \([0-9]*\).*' )

    if len(l:match_list)
        let s:cmd = "tag " . l:match_list[1]
        let status = v:true
    endif

    return status
endfunction

" Emulate 'gf' but recognize :line format
" Code from: https://github.com/amix/open_file_under_cursor.vim
function! s:local_file()
    let l:word_under_cursor = expand("<cfile>")
    if (strlen(l:word_under_cursor) == 0)
        return v:false
    endif

    let matchstart = match(l:word_under_cursor, ':\d\+$')
    if matchstart > 0
        let pos = '+' . strpart(l:word_under_cursor, matchstart+1)
        let fname = strpart(l:word_under_cursor, 0, matchstart)
    else
        let pos = ""
        let fname = l:word_under_cursor
    endif

    " Check exists file.
    if filereadable(fname)
        let fullname = fname
    else
        " try find file with prefix by working directory
        let fullname = getcwd() . '/' . fname
        if !filereadable(fullname)
            " the last try, using current directory based on file opened.
            let fullname = expand('%:h') . '/' . fname
        endif
    endif

    " Use 'find' so path is searched like 'gf' would
    let s:cmd ='find ' . pos . ' ' . fname
    return v:true
endfunction

function s:url()
    " Source: https://gist.github.com/tobym/584909
    let l:matched = matchstr(
                \ s:file_line,
                \ '\(https\|http\)\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*'
                \ )

    if len(l:matched) > 0
        if has("win32")
            let s:cmd = "!explorer.exe " . l:matched
        else
            let s:cmd = "!open " . l:matched
        endif

        return v:true
    endif

    return v:false
endfunction

let s:parsers = [
    \ function("s:include_from"),
    \ function("s:msvc_error"),
    \ function("s:grep_output"),
    \ function("s:include_statement"),
    \ function("s:msvc_stack"),
    \ function("s:url"),
    \ function("s:local_file"),
    \ ]

function! goto#run()
    let s:file_line = getline(".")

    if len(s:file_line) == 0
        return
    endif

    let l:processed = v:false
    for F in s:parsers
        if F()
            let l:processed = v:true

            try
                exec s:cmd
                break
            catch
                echohl ErrorMsg
                echo "Cannot find file in line."
                echohl Normal
            endtry
        endif
    endfor

    if !l:processed
        echohl ErrorMsg
        echo "Parsing of the current line failed."
        echohl Normal
    endif

    let s:file_line = ""
endfunction
