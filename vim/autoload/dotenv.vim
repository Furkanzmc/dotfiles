function s:log_error(message)
    echohl ErrorMsg
    echomsg "[dotenv] " . a:message
    echohl Normal
endfunction

function dotenv#source(env_file)
    let l:env_file = expand(a:env_file)
    if !filereadable(l:env_file)
        call s:log_error("Cannot read '" . l:env_file . "'")
        return
    endif

    let l:lines = readfile(l:env_file)
    for line in l:lines
        if !s:is_env_line(line)
            continue
        endif
        let l:var_name = s:get_env_var_name(line)
        if exists("$" . l:var_name)
            execute "let $" . l:var_name . "_ORIGINAL='" . getenv(l:var_name) . "'"
        endif

        execute "let $" . line
    endfor
endfunction

function dotenv#deactivate(env_file)
    let l:env_file = expand(a:env_file)
    if !filereadable(l:env_file)
        call s:log_error("Cannot read '" . l:env_file . "'")
        return
    endif

    let l:lines = readfile(l:env_file)
    for line in l:lines
        if !s:is_env_line(line)
            continue
        endif

        let l:var_name = s:get_env_var_name(line)
        if !exists("$" . l:var_name)
            continue
        endif

        let l:orig_var_name = l:var_name . "_ORIGINAL"
        if exists("$" . l:orig_var_name)
            execute "let $" . l:var_name . "='" . getenv(l:orig_var_name) . "'"
            execute "unlet $" . l:orig_var_name
        else
            execute "unlet $" . l:var_name
        endif
    endfor
endfunction

function s:is_env_line(line)
    if a:line =~ "^#"
        return v:false
    elseif empty(a:line)
        return v:false
    elseif a:line =~ '^[aA-zZ]\+\(\ = \|=\)\([0-9]\+\|\"\([aA-zZ]\+\|.\).*\"\)'
        return v:true
    else
        call s:log_error("'" . a:line . "' is not an environment variable declaration.")
        return v:false
    endif
endfunction

function s:get_env_var_name(line)
    let l:components = split(a:line, "=")
    return trim(l:components[0])
endfunction

function s:get_env_var_value(line)
    let l:components = split(a:line, "=")
    return trim(l:components[1])
endfunction
