if !get(s:, "vimrc_python_plugins_loaded", v:false)
    packadd vim-python-pep8-indent
    packadd tagbar
    let s:vimrc_python_plugins_loaded = v:true
endif

" Python indentation
syn keyword pythonDecorator True None False self

setlocal cindent
setlocal cinkeys-=0#
setlocal indentkeys-=0#

setlocal expandtab
setlocal autoindent
setlocal foldmethod=indent

setlocal signcolumn=yes
setlocal wildignore+=*.pyc,__pycache__

nmap <buffer><silent> <leader>pi :call python#get_pylint_error_message(expand("<cword>"))<CR>

if !exists("b:lsp_location_list_enabled")
    let b:lsp_location_list_enabled = 0
endif

if !exists("b:lsp_virtual_text_enabled")
    let b:lsp_virtual_text_enabled = 0
endif

if !exists("b:lsp_signs_enabled")
    let b:lsp_signs_enabled = 0
endif
