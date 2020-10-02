" Syntax from: https://github.com/freitass/todo.txt-vim/blob/master/syntax/todo.vim
" Example: {{{
" [ ] (A) A todo item. +Project @Context
" [x] (A) Prepend `x` to mark it as done.
" [ ] (B) A todo item with a subtask.
"     [ ] Here's a subtask.
"     > It can contain comments.
"       [ ] Or nested tasks.
"       > With nested comments.
"       > You can also include code here:
"       ```python
"       import this
"       ```
" [i] (A) Prepend `i` to mark a todo in progress.
" }}}
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
    setlocal foldexpr=todo#foldexpr(v:lnum)
    setlocal conceallevel=2
endfunction

let b:done_task_pattern = '\(^\[[xX]\]\|^\ \{4,\}\[[xX]\]\)\s.\+$'
let b:task_pattern  ='^\ \{4,\}\[\ \]'
let b:comment_patten = '^\ \{4,\}>\s.\+$'

syntax match TodoDate '\d\{2,4\}-\d\{2\}-\d\{4\}' contains=NONE
syntax match TodoTime '\d\{2\}:\d\{2\}' contains=TodoDate
syntax match TodoProject '\(^\|\W\)+[^[:blank:]]\+' contains=NONE
syntax match TodoContext '\(^\|\W\)@[^[:blank:]]\+' contains=NONE

syntax match TodoLeadingWhiteSpace '^\ \{1,\}' contains=NONE
syntax match TodoDone '\(^\[[xX]\]\|^\ \{4,\}\[[xX]\]\)\s.\+$' contains=TodoLeadingWhiteSpace
syntax match TodoInProgress '\(^\[[iI]\]\|^\ \{4,\}\[[iI]\]\)' contains=TodoLeadingWhiteSpace

syntax match TodoPriorityA '\(^\(\[\ \]\|\[[iI]\]\)\|^\ \{4,\}\(\[\ \]\|\[[iI]\]\)\) ([aA])\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityB '\(^\(\[\ \]\|\[[iI]\]\)\|^\ \{4,\}\(\[\ \]\|\[[iI]\]\)\) ([bB])\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityC '\(^\(\[\ \]\|\[[iI]\]\)\|^\ \{4,\}\(\[\ \]\|\[[iI]\]\)\) ([cC])\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityD '\(^\(\[\ \]\|\[[iI]\]\)\|^\ \{4,\}\(\[\ \]\|\[[iI]\]\)\) ([dD])\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate

syntax match TodoComment '^\ \{4,\}>\s.\+$'
syntax match TodoSubTask '\(^\ \{4,\}\[[iI]\]\|^\ \{4,\}\[ \]\)\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate,TodoPriorityA,TodoPriorityB,TodoPriorityB,TodoPriorityC,TodoPriorityD


" Other priority colours might be defined by the user
highlight default link TodoDone Comment
highlight default link TodoInProgress WarningMsg
highlight default link TodoPriorityA Identifier

highlight default link TodoPriorityB Constant
highlight default link TodoPriorityC Type
highlight default link TodoPriorityD SpecialKey

highlight default link TodoDate PreProc
highlight default link TodoTime PreProc
highlight default link TodoProject SpecialKey
highlight default link TodoContext Label

highlight default link TodoComment String
highlight default link TodoSubTask NONE

augroup syn_todo
    au!
    autocmd BufReadPost,FilterReadPost,FileReadPost,FileReadCmd todo.txt
                \ :call s:enable_highlight()
augroup END

call s:enable_highlight()

call matchadd('Conceal', '^\ \{4,\}```[a-z]\+$', 10, -1, {'conceal':' '})
call matchadd('Conceal', '^\ \{4,\}```$', 10, -1, {'conceal':' '})

let b:current_syntax = "todo"
