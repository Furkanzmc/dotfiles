setlocal scrollback=-1
setlocal nowrap
set scrolloff=0
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn=no

" Jump to the previous shell prompt
nmap <buffer> <silent> [p ?^\(!!\ =>\\|=>\)<CR><leader><CR>
" Jump to the next shell prompt
nmap <buffer> <silent> ]p /^\(!!\ =>\\|=>\)<CR><leader><CR>

" Jump to the previous pytest error
nmap <buffer> <silent> [e ?^_\{10,\}\ \w\+.*\ _\{10,\}<CR><leader><CR>
" Jump to the next pytest error
nmap <buffer> <silent> ]e /^_\{10,\}\ \w\+.*\ _\{10,\}<CR><leader><CR>

function! terminal#cleanup()
    set scrolloff=3
endfunction

autocmd TermLeave * call terminal#cleanup()
autocmd TermEnter * set scrolloff=0

tmap <C-d> <PageDown>
tmap <C-u> <PageUp>
tnoremap <C-w>q <C-\><C-n>
