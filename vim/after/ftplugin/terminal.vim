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

nmap <buffer> <silent> [e :TerminalPreviousError<CR>
nmap <buffer> <silent> ]e :TerminalNextError<CR>

" Jump to the previous Python prompt
nmap <buffer> <silent> [p :call search("^>>>", "Wb")<CR>
" Jump to the next Python prompt
nmap <buffer> <silent> ]p :call search("^>>>", "W")<CR>

if get(b:, "did_terminal", v:false)
    finish
endif

autocmd TermEnter <buffer> set scrolloff=0
autocmd TermEnter,BufEnter,WinEnter <buffer> call setreg("t", trim(@*) . "")
autocmd TermLeave <buffer> set scrolloff=3

command -buffer TerminalNextError call search('\(^_\{10,}\ \w\+.*\ _\{10,}\|^=\{10,\}\)', 'W')
command -buffer TerminalPreviousError call search('\(^_\{10,}\ \w\+.*\ _\{10,}\|^=\{10,\}\)', 'Wb')

let b:did_terminal = v:true
