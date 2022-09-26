" Syntax from: https://github.com/freitass/todo.txt-vim/blob/master/syntax/todo.vim
" Example: {{{
" - [ ] (A) A todo item. +Project @Context
" - [x] (A) Prepend `x` to mark it as done.
" - [~] (A) This task will no longer be worked on but here for recording.
" - [ ] (B) A todo item with a subtask.
"     - [ ] Here's a subtask.
"       > It can contain comments.
"     - [ ] Or nested tasks.
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

let b:done_task_pattern = '\(^\[[xX]\]\|^\ \{4,\}\[[xX]\]\)\s.\+$'
let b:removed_task_pattern = '\(^\[[\~]\]\|^\ \{4,\}\[[\~]\]\)\s.\+$'
let b:task_pattern  ='^\ \{4,\}\[\ \]'
let b:comment_patten = '^\ \{4,\}>\s.\+$'

syntax match TodoDate '\d\{2,4\}-\d\{2\}-\d\{4\}' contains=NONE
syntax match TodoTime '\d\{2\}:\d\{2\}' contains=TodoDate
syntax match TodoProject '\(^\|\W\)+[^[:blank:]]\+' contains=NONE
syntax match TodoContext '\(^\|\W\)@[^[:blank:]]\+' contains=NONE

syntax match TodoLeadingWhiteSpace '^-\ \ \{1,\}' contains=NONE
syntax match TodoDone '\(-\ \[[xX]\]\|-\ \ \{4,\}\[[xX]\]\)\s.\+$' contains=TodoLeadingWhiteSpace
syntax match TodoRemoved '\(-\ \[[\~]\]\|-\ \ \{4,\}\[[\~]\]\)\s.\+$' contains=TodoLeadingWhiteSpace
syntax match TodoInProgress '\(-\ \[[iI]\]\|-\ \ \{4,\}\[[iI]\]\)' contains=TodoLeadingWhiteSpace

syntax match TodoPriorityA '\(-\ \(\[\ \]\|\[[iI]\]\)\|-\ \ \{4,\}\(\[\ \]\|\[[iI]\]\)\) ([aA])\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityB '\(-\ \(\[\ \]\|\[[iI]\]\)\|-\ \ \{4,\}\(\[\ \]\|\[[iI]\]\)\) ([bB])\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate
syntax match TodoPriorityC '\(-\ \(\[\ \]\|\[[iI]\]\)\|-\ \ \{4,\}\(\[\ \]\|\[[iI]\]\)\) ([cC])\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate

syntax match TodoPriorityD '\(-\ \(\[\ \]\|\[[iI]\]\)\|-\ \ \{4,\}\(\[\ \]\|\[[iI]\]\)\) ([dD])\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate

syntax match TodoComment '^\ \{4,\}>\s.\+$'
syntax match TodoSubTask '\(-\ \ \{4,\}\[[iI]\]\|-\ \ \{4,\}\[ \]\)\s.\+$' contains=TodoInProgress,TodoDate,TodoTime,TodoProject,TodoContext,OverDueDate,TodoPriorityA,TodoPriorityB,TodoPriorityB,TodoPriorityC,TodoPriorityD


" Other priority colours might be defined by the user
highlight default link TodoDone Comment
highlight default link TodoRemoved DiffDelete
highlight default link TodoInProgress WarningMsg
highlight default link TodoPriorityA Identifier

highlight default link TodoPriorityB Constant
highlight default link TodoPriorityC Type
highlight default link TodoPriorityD SpecialKey

highlight default link TodoDate PreProc
highlight default link TodoTime PreProc
highlight default link TodoProject SpecialKey
highlight default link TodoContext Label

highlight default link TodoComment Comment
highlight default link TodoSubTask NONE

call matchadd('Conceal', '^\ \{4,\}```[a-z]\+$', 10, -1, {'conceal':' '})
call matchadd('Conceal', '^\ \{4,\}```$', 10, -1, {'conceal':' '})

let b:current_syntax = "todo"
