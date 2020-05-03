function! markdown#enable_highlight()
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

autocmd BufNewFile,BufReadPost,FilterReadPost,FileReadPost *.md
            \ :call markdown#enable_highlight()
autocmd BufEnter *.md :call markdown#enable_highlight()

setlocal spell
setlocal colorcolumn=80,100
