nmap <silent> gh :call help#search_docs()<CR>
command! -nargs=1 Search :call help#search_docs(<f-args>)
