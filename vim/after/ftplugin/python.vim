if !get(s:, "vimrc_python_plugins_loaded", v:false)
    packadd tagbar
    let s:vimrc_python_plugins_loaded = v:true
endif

function python#includeexpr(fname)
    let l:search_paths = [".venv/lib/*/site-packages"]
    return includeexpr#find(substitute(a:fname, "\\.", "\/", "g"), l:search_paths)
endfunction

setlocal cindent
setlocal expandtab
setlocal autoindent

setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal wildignore+=*.pyc,__pycache__

setlocal shiftwidth=4
setlocal tabstop=4
setlocal softtabstop=4

setlocal nosmarttab
setlocal linebreak
setlocal textwidth=120

setlocal indentexpr=
setlocal includeexpr=python#includeexpr(v:fname)
setlocal suffixesadd=.py

nmap <buffer><silent> <leader>pi :call python#get_pylint_error_message(expand("<cword>"))<CR>

" Abbreviations {{{

inoremap <buffer> <c-l>ff <ESC>bidef <ESC>$a():<Left><Left>

" }}}

if !exists("b:vimrc_lsp_location_list_enabled")
    let b:vimrc_lsp_location_list_enabled = 0
endif

if !exists("b:vimrc_lsp_virtual_text_enabled")
    let b:vimrc_lsp_virtual_text_enabled = 0
endif

if !exists("b:vimrc_lsp_signs_enabled")
    let b:vimrc_lsp_signs_enabled = 0
endif
