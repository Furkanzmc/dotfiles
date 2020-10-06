if !get(s:, "vimrc_python_plugins_loaded", v:false)
    packadd vim-python-pep8-indent
    packadd tagbar
    let s:vimrc_python_plugins_loaded = v:true
endif

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
setlocal textwidth=90

setlocal indentexpr=

nmap <buffer><silent> <leader>pi :call python#get_pylint_error_message(expand("<cword>"))<CR>

if !exists("b:vimrc_lsp_location_list_enabled")
    let b:vimrc_lsp_location_list_enabled = 0
endif

if !exists("b:vimrc_lsp_virtual_text_enabled")
    let b:vimrc_lsp_virtual_text_enabled = 0
endif

if !exists("b:vimrc_lsp_signs_enabled")
    let b:vimrc_lsp_signs_enabled = 0
endif
