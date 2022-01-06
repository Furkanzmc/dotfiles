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

function! fold#fold_text()
    let l:fold_char = get(b:, 'foldchar', '━')
    let l:strip_comments = get(b:, 'foldtext_strip_comments', v:true)
    let l:strip_add_regex = get(b:, 'foldtext_strip_add_regex', '')

    let l:line = getline(v:foldstart)
    let l:foldlevel = repeat(l:fold_char, v:foldlevel)
    let l:fold_indent = repeat(
                \ '━',
                \ max([indent(v:foldstart) - strdisplaywidth(l:foldlevel),
                \     strdisplaywidth(l:fold_char)])
                \ )
    let l:line_count = line("$")
    let l:fold_lines = float2nr(((v:foldend - v:foldstart + 1) / (l:line_count * 1.0)) * 100)

    " Always strip away fold markers
    let l:strip_regex = '\%(\s*{{{\d*\s*\)'
    if l:strip_comments
        let l:strip_regex .= '\|\%(^\s*'
                \. substitute(&commentstring, '\s*%s\s*', '', '')
                \. '*\s*\)'
    endif

    let l:line = substitute(l:line, l:strip_regex, '', 'g')
    " Additional per buffer strip
    if l:strip_add_regex != ""
        let l:line = substitute(l:line, l:strip_add_regex, '', 'g')
    endif

    let l:line = substitute(l:line, '^\s*\|\s*$', '', 'g')
    let l:non_text_len = strdisplaywidth(l:foldlevel.fold_indent.fold_lines.' ()')
    let l:fold_text = strcharpart(l:line, 0, winwidth(0) - l:non_text_len)

    if get(b:, 'foldlines_padding', v:false)
        let l:foldless_padding = repeat(
                    \ ' ',
                    \ winwidth(0) - strdisplaywidth(l:fold_text) - l:non_text_len + 1)
    else
        let l:foldless_padding = ' '
    endif

    return printf("%s%s┫ %s%s[%d/%d%%]",
                \ l:foldlevel,
                \ l:fold_indent,
                \ l:fold_text,
                \ l:foldless_padding,
                \ l:line_count,
                \ l:fold_lines)
endfunction
