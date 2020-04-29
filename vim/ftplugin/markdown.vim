function! markdown#enable_highlight()
    if get(b:, "markdown_highlight_enabled", v:false)
        return
    endif

    call SyntaxRange#Include('```qml', '```', 'qml', 'NonText')
    call SyntaxRange#Include('```css', '```', 'css', 'NonText')
    call SyntaxRange#Include('```html', '```', 'html', 'NonText')

    call SyntaxRange#Include('```cpp', '```', 'cpp', 'NonText')
    call SyntaxRange#Include('```json', '```', 'json', 'NonText')
    call SyntaxRange#Include('```python', '```', 'python', 'NonText')
    call SyntaxRange#Include('```js', '```', 'javascript', 'NonText')

    let b:markdown_highlight_enabled = v:true
endfunction

autocmd BufNewFile,BufReadPost,FilterReadPost,FileReadPost *.md
            \ :call markdown#enable_highlight()
autocmd BufEnter *.md :call markdown#enable_highlight()

setlocal spell
setlocal colorcolumn=80,100
