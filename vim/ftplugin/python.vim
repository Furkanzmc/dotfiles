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

if executable("black")
    setlocal formatprg=black\ --line-length=80\ --quiet\ -
endif
