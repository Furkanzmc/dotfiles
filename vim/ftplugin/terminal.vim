setlocal scrollback=-1
setlocal nowrap
set scrolloff=0

setlocal nonumber
setlocal norelativenumber

" Jump to the previous shell prompt
nmap <buffer> <silent> [t :call search('^\(!!\ =>\\|=>\)', 'Wb')<CR>
" Jump to the next shell prompt
nmap <buffer> <silent> ]t :call search('^\(!!\ =>\\|=>\)', 'W')<CR>

" Jump to the previous pytest error
nmap <buffer> <silent> [e :call search('^_\{10,\}\ \w\+.*\ _\{10,\}', 'Wb')<CR>
" Jump to the next pytest error
nmap <buffer> <silent> ]e :call search('^_\{10,}\ \w\+.*\ _\{10,}', 'W')<CR>

" Jump to the previous Python prompt
nmap <buffer> <silent> [p :call search("^>>>", "Wb")<CR>
" Jump to the next Python prompt
nmap <buffer> <silent> ]p :call search("^>>>", "W")<CR>

augroup Terminal
    autocmd!

    autocmd TermEnter * set scrolloff=0
    autocmd TermLeave * set scrolloff=3
augroup END

tmap <C-d> <PageDown>
tmap <C-u> <PageUp>
tnoremap <C-w>q <C-\><C-n>
