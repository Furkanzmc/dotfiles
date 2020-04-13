" Taken from: https://github.com/habamax/.vim/blob/master/foldtext.vim
" My fancy foldtext
" Per buffer setup:
"
" char to be used for folding
" let b:foldchar = ''
"
" add padding to fold line count (pad to the right)
" let b:foldlines_padding = v:false
"
" strip leading comment chars
" let b:foldtext_strip_comments = v:true
"
" additional regexp to strip foldtext (example for asciidoctor buffers)
" let b:foldtext_strip_add_regex = '^=\+'

" fasd as {{
function! fold#fold_text()
    let foldchar = get(b:, 'foldchar', '>')
    let strip_comments = get(b:, 'foldtext_strip_comments', v:false)
    let strip_add_regex = get(b:, 'foldtext_strip_add_regex', '')

    let line = getline(v:foldstart)
    let indent = indent(v:foldstart)

    let foldlevel = repeat(foldchar, v:foldlevel)
    let foldindent = repeat(
                \ ' ',
                \ max([indent - strdisplaywidth(foldlevel),
                \     strdisplaywidth(foldchar)])
                \ )
    let foldlines = (v:foldend - v:foldstart + 1)

    " Always strip away fold markers
    let strip_regex = '\%(\s*{{{\d*\s*\)'
    if strip_comments
        let strip_regex .= '\|\%(^\s*'
                \. substitute(&commentstring, '\s*%s\s*', '', '')
                \. '*\s*\)'
    endif

    let line = substitute(line, strip_regex, '', 'g')

    " Additional per buffer strip
    if strip_add_regex != ""
        let line = substitute(line, strip_add_regex, '', 'g')
    endif

    let line = substitute(line, '^\s*\|\s*$', '', 'g')

    let nontextlen = strdisplaywidth(foldlevel.foldindent.foldlines.' ()')
    let foldtext = strcharpart(line, 0, winwidth(0) - nontextlen)

    if get(b:, 'foldlines_padding', v:false)
        let foldlines_padding = repeat(
                    \ ' ',
                    \ winwidth(0) - strdisplaywidth(foldtext) - nontextlen + 1)
    else
        let foldlines_padding = ' '
    endif

    return printf("%s%s%s%s(%d)",
                \ foldlevel,
                \ foldindent,
                \ foldtext,
                \ foldlines_padding,
                \ foldlines)
endfunction
" }}

function! fold#set_foldtext()
    if &foldtext == "foldtext()" && &foldtext != "fold#fold_text()"
        setlocal foldtext=fold#fold_text()
    endif
endfunction

autocmd BufReadPost * call fold#set_foldtext()
autocmd BufNew * call fold#set_foldtext()
autocmd BufEnter * call fold#set_foldtext()
