setlocal colorcolumn=
setlocal signcolumn=no
setlocal cursorline

function! s:enable_highlight()
    call SyntaxRange#Include('```qml', '```', 'qml', 'NonText')
    call SyntaxRange#Include('```css', '```', 'css', 'NonText')
    call SyntaxRange#Include('```html', '```', 'html', 'NonText')

    call SyntaxRange#Include('```cpp', '```', 'cpp', 'NonText')
    call SyntaxRange#Include('```json', '```', 'json', 'NonText')
    call SyntaxRange#Include('```python', '```', 'python', 'NonText')
    call SyntaxRange#Include('```js', '```', 'javascript', 'NonText')

    setlocal foldmethod=expr
    setlocal conceallevel=2
endfunction

autocmd BufNewFile,BufReadPost,FilterReadPost,FileReadPost todo.txt
            \ :call s:enable_highlight()
autocmd BufEnter todo.txt :call s:enable_highlight()
