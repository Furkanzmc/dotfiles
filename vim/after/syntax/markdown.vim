if exists("b:markdown_conceal_set")
    finish
endif

function! s:enable_highlight()
    call SyntaxRange#Include('```qml', '```', 'qml', 'NonText')
    call SyntaxRange#Include('```css', '```', 'css', 'NonText')
    call SyntaxRange#Include('```html', '```', 'html', 'NonText')

    call SyntaxRange#Include('```cpp', '```', 'cpp', 'NonText')
    call SyntaxRange#Include('```json', '```', 'json', 'NonText')
    call SyntaxRange#Include('```python', '```', 'python', 'NonText')
    call SyntaxRange#Include('```js', '```', 'javascript', 'NonText')
    call SyntaxRange#Include('```diff', '```', 'diff', 'NonText')

    setlocal foldmethod=expr
    setlocal conceallevel=2
endfunction

augroup syn_markdown
    au!

    autocmd BufReadPost,FilterReadPost,FileReadPost,FileReadCmd *.md
                \ :call s:enable_highlight()
augroup END

call s:enable_highlight()

call matchadd('Conceal', '^```[a-z]\+$', 10, -1, {'conceal':' '})
call matchadd('Conceal', '^```$', 10, -1, {'conceal':' '})

let b:markdown_conceal_set = v:true
