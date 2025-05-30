if get(b:, "did_ftp", v:false)
    finish
end

if !get(s:, "vimrc_python_plugins_loaded", v:false) && &loadplugins
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
setlocal textwidth=120

setlocal indentexpr=
setlocal includeexpr=python#includeexpr(v:fname)
setlocal suffixesadd=.py

setlocal nocursorcolumn

if executable("black")
    setlocal formatprg=black\ --quiet\ -
endif

let b:vimrc_null_ls_lsp_signs_enabled = 1
let b:vimrc_pyright_lsp_signs_enabled = 1

" Abbreviations {{{

abbreviate <silent> <buffer> im@ import <C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> imdt@ from datetime import datetime<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> imtz@ from django.utils import timezone<C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> im_@ from django.utils.translation import ugettext_lazy as _<C-R>=abbreviations#eat_char('\s')<CR>

abbreviate <silent> <buffer> pr@ print("[lame_debugging::<C-r>=expand("%:t")<CR>::<C-r>=line('.')<CR>]")<Esc>F"a,<Space><C-R>=abbreviations#eat_char('\s')<CR>

abbreviate <silent> <buffer> true True
abbreviate <silent> <buffer> false False

" }}}

function python#includeexpr(fname)
    let l:search_paths = [".venv/lib/*/site-packages"]
    return includeexpr#find(substitute(a:fname, "\\.", "\/", "g"), l:search_paths)
endfunction
