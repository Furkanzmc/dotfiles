function find#complete(arg_lead, cmd_line, cursor_pos)
  return luaeval("require'vimrc.find'.complete('" . a:arg_lead . "', '" . a:cmd_line . "', '" . a:cursor_pos . "')")
endfunction
