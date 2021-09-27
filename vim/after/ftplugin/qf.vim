if get(b:, "did_ftp", v:false)
    finish
endif

setlocal nonumber
setlocal norelativenumber
setlocal colorcolumn=
setlocal breakindentopt=shift:1

setlocal cursorline
execute "Setlocal trailingwhitespacehighlight=false"

vmap <buffer> <silent> D :<C-U>call quickfix#remove_lines(line("'<") - 1, line("'>") - 1)<CR>
nmap <buffer> <silent> D :call quickfix#remove_lines(line(".") - 1, line(".") - 1)<CR>
nmap <buffer> <silent> CC :call setqflist([])<CR>

augroup vimrc_ft_quickfix
    au!
    autocmd BufLeave <buffer> :if exists("g:vimrc_quickfix_size_cache") | let g:vimrc_quickfix_size_cache[tabpagenr()] = winheight(winnr()) | else | let g:vimrc_quickfix_size_cache = {tabpagenr(): winheight(winnr())} | endif
augroup END
