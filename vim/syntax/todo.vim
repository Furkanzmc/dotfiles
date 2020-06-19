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

    setlocal foldmethod=indent
    setlocal conceallevel=2
endfunction

syntax match TodoDate '\d\{2,4\}-\d\{2\}-\d\{2\}' contains=NONE
syntax match TodoProject '\(^\|\W\)+[^[:blank:]]\+' contains=NONE
syntax match TodoContext '\(^\|\W\)@[^[:blank:]]\+' contains=NONE

syntax match TodoDone '^[xX]\s.\+$'
syntax match TodoInProgress '^[iI] ' contains=NONE
syntax match TodoPriorityA '\(^[iI] ([aA])\|^([aA])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityB '\(^[iI] ([bB])\|^([bB])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityC '\(^[iI] ([cC])\|^([cC])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityD '\(^[iI] ([dD])\|^([dD])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityE '\(^[iI] ([eE])\|^([eE])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityF '\(^[iI] ([fF])\|^([fF])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityG '\(^[iI] ([gG])\|^([gG])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityH '\(^[iI] ([hH])\|^([hH])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityI '\(^[iI] ([iI])\|^([iI])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityJ '\(^[iI] ([jJ])\|^([jJ])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityK '\(^[iI] ([kK])\|^([kK])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityL '\(^[iI] ([lL])\|^([lL])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityM '\(^[iI] ([mM])\|^([mM])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityN '\(^[iI] ([nN])\|^([nN])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityO '\(^[iI] ([oO])\|^([oO])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityP '\(^[iI] ([pP])\|^([pP])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityQ '\(^[iI] ([qQ])\|^([qQ])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityR '\(^[iI] ([rR])\|^([rR])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityS '\(^[iI] ([sS])\|^([sS])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityT '\(^[iI] ([tT])\|^([tT])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityU '\(^[iI] ([uU])\|^([uU])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityV '\(^[iI] ([vV])\|^([vV])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityW '\(^[iI] ([wW])\|^([wW])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityX '\(^[iI] ([xX])\|^([xX])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityY '\(^[iI] ([yY])\|^([yY])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityZ '\(^[iI] ([zZ])\|^([zZ])\)\s.\+$' contains=TodoInProgress,TodoDate,TodoProject,TodoContext,OverDueDate
syntax match TodoComment '^\(|->\|  \)\s.\+$'
syntax match TodoSubTask '    +\s.\+$'


" Other priority colours might be defined by the user
highlight default link TodoDone Comment
highlight default link TodoInProgress IncSearch
highlight default link TodoPriorityA Identifier

highlight default link TodoPriorityB Constant
highlight default link TodoPriorityC Type
highlight default link TodoPriorityD SpecialKey

highlight default link TodoDate PreProc
highlight default link TodoProject Label
highlight default link TodoContext Label

highlight default link TodoComment Comment
highlight default link TodoSubTask Question

autocmd BufReadPost,FilterReadPost,FileReadPost,FileReadCmd todo.txt
            \ :call s:enable_highlight()

call s:enable_highlight()

call matchadd('Conceal', '   ```[a-z]\+$', 10, -1, {'conceal':' '})
call matchadd('Conceal', '   ```$', 10, -1, {'conceal':' '})

let b:current_syntax = "todo"
