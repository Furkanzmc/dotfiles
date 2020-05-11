" Syntax from: https://github.com/freitass/todo.txt-vim/blob/master/syntax/todo.vim
if exists("b:current_syntax")
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

    setlocal foldmethod=expr
    setlocal conceallevel=2
endfunction

syntax match TodoDate '\d\{2,4\}-\d\{2\}-\d\{2\}' contains=NONE
syntax match TodoProject '\(^\|\W\)+[^[:blank:]]\+' contains=NONE
syntax match TodoContext '\(^\|\W\)@[^[:blank:]]\+' contains=NONE

syntax match TodoDone '^[xX]\s.\+$'
syntax match TodoPriorityA '^([aA])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityB '^([bB])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityC '^([cC])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityD '^([dD])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityE '^([eE])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityF '^([fF])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityG '^([gG])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityH '^([hH])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityI '^([iI])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityJ '^([jJ])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityK '^([kK])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityL '^([lL])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityM '^([mM])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityN '^([nN])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityO '^([oO])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityP '^([pP])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityQ '^([qQ])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityR '^([rR])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityS '^([sS])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityT '^([tT])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityU '^([uU])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityV '^([vV])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityW '^([wW])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityX '^([xX])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityY '^([yY])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityZ '^([zZ])\s.\+$' contains=TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoComment '^\(|->\|  \)\s.\+$'
syntax match TodoSubTask '    +\s.\+$'


" Other priority colours might be defined by the user
highlight default link TodoDone Comment
highlight default link TodoPriorityA Constant
highlight default link TodoPriorityB Statement

highlight default link TodoPriorityC Identifier
highlight default link TodoPriorityD Type
highlight default link TodoDate PreProc

highlight default link TodoProject Special
highlight default link TodoContext Special
highlight default link TodoComment Comment

highlight default link TodoSubTask Question

autocmd BufReadPost,FilterReadPost,FileReadPost,FileReadCmd todo.txt
            \ :call s:enable_highlight()

call markdown#enable_highlight()

call matchadd('Conceal', '   ```[a-z]\+$', 10, -1, {'conceal':' '})
call matchadd('Conceal', '   ```$', 10, -1, {'conceal':' '})

let b:current_syntax = "todo"
