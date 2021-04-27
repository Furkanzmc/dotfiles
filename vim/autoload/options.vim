function options#complete(arg_lead, L, P)
    return luaeval("require'vimrc.options'.list_options('" . a:arg_lead . "')")
endfunction

function options#complete_buf_local(arg_lead, L, P)
    return luaeval("require'vimrc.options'.list_options('" . a:arg_lead . "', true)")
endfunction

function options#get(name)
    return luaeval("require'vimrc.options'.get_option('" . a:name . "')")
endfunction

function options#set(name, value)
    return luaeval("require'vimrc.options'.set('" . a:name . "=" . a:value . "')")
endfunction
