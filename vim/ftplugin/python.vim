if !get(s:, "vimrc_python_plugins_loaded", v:false)
    packadd vim-python-pep8-indent
    packadd tagbar
    packadd ale
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

setlocal formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
setlocal wildignore+=*.pyc,__pycache__

autocmd BufWritePre *.py :call buffers#clean_extra_spaces()

if executable("black")
    setlocal formatprg=black\ --line-length=80\ --quiet\ -
endif
