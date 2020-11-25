setlocal scrollback=-1
setlocal nowrap
set scrolloff=0

setlocal nonumber
setlocal norelativenumber
setlocal cursorline

setlocal signcolumn=no

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

" Pastes the text in the register into the terminal.
nmap <buffer> <leader>p :call <SID>send_to_terminal()<CR>

if get(s:, "terminal_plugin_loaded", v:false)
    finish
endif

augroup vimrc_terminal
    autocmd!

    autocmd TermEnter * set scrolloff=0
    autocmd TermEnter,BufEnter,WinEnter <buffer> call setreg("t", trim(@*) . "")
    autocmd TermLeave * set scrolloff=3
augroup END

let s:terminal_plugin_loaded = v:true
