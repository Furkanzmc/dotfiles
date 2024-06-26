" Syntax from: https://github.com/ryanolsonx/vim-xit/blob/main/syntax/xit.vim
" Example: {{{
" - [ ] A todo item with a project and a context +Project #Context
" - [ ] !! You can use exclamation marks to indicate the priority of the task
" - [ ] You can use `start-date` and `end-date` to indicate when this task should be worked on start-date: 31-04-2024-13:30 end-date: 31-04-2024-14:30
" - [x] You can add `x` to mark the task as finished.
" - [x] You can add `started` and `finished` to indicate when you started working on a task and when you finished it started: 31-04-2024-13:30 finished: 31-04-2024-14:30
" - [~] This task will no longer be worked on but here for recording.
" - [ ] You can have a to do item with subtasks
    " - [ ] Here's a subtask.
      " > It can contain comments.
    " - [ ] Nested tasks can also have other nested tasks
        " - [ ] Here's a subtask
    " - [ ] Or nested tasks.
      " > With nested comments.
      " > You can also include code here:
        " ```cpp
        " #include <iostream>
        " ```
" - [-] Prepend `-` to mark a todo in progress. started: 03-10-2022-23:33
" }}}
if exists("b:current_syntax")
    finish
endif

" Matches a checkbox like "- [ ]"
syn region TodoCheckboxOpen start=/\- \[ /ms=s+2 end=/\v\]/me=e nextgroup=TodoCheckboxOpenSpace contains=TodoLeadingSpace
syn match TodoLeadingSpace '^\ \ \{1,\}' contains=NONE nextgroup=TodoCheckboxOpenSpace
syn match TodoCheckboxOpenSpace " " nextgroup=TodoCheckboxOpenPriority contained
" Matches a priority. Spaces followed by periods followed by exclaimation followed by a space. If it
" doesn't match, it continues on to the description for the checkbox.
syn match TodoCheckboxOpenPriority "\v( *\.*!* ){,1}" nextgroup=TodoCheckboxOpenDesc contained
" This matches a multiline open checkbox description. It starts right away with any char and ends at
" the beginning of the next checkbox or next group title. /me=e-1 means match to the end offset by
" one so that it doesn't include the first char of a title or the "[".
syn region TodoCheckboxOpenDesc start="." end=/\v- \[/me=e-4 contained contains=TodoTag,TodoProject,TodoContext,TodoDueDate,TodoLeadingSpace,TodoComment,TodoStarted,TodoFinished,TodoDateTime,TodoDueAt,TodoStartDate,TodoEndDate

" Matches a checkbox like "- [x]"
syn region TodoCheckboxChecked start=/\- \[x/ms=s+2 end=/\v\]/me=e nextgroup=TodoCheckboxCheckedSpace contains=TodoLeadingSpace
syn match TodoCheckboxCheckedSpace " " nextgroup=TodoCheckboxCheckedPriority contained
" Matches a priority. Spaces followed by periods followed by exclaimation followed by a space. If it doesn't
" match, it continues on to the description for the checkbox.
syn match TodoCheckboxCheckedPriority "\v( *\.*!* ){,1}" nextgroup=TodoCheckboxCheckedDesc contained
" This matches a multiline checked checkbox description. It starts right away with any char and ends
" at the beginning of the next checkbox or next group title. /me=e-1 means match to the end offset
" by one so that it doesn't include the first char of a title or the "[".
syn region TodoCheckboxCheckedDesc start="." end=/\v- \[/me=e-4 contained contains=TodoTag,TodoProject,TodoContext,TodoDueDate,TodoLeadingSpace,TodoComment,TodoStarted,TodoFinished,TodoDateTime,TodoDueAt,TodoStartDate,TodoEndDate

" Matches a checkbox like "- [-]"
syn region TodoCheckboxOngoing start=/\- \[-/ms=s+2 end=/\v\]/me=e nextgroup=TodoCheckboxOngoingSpace contains=TodoLeadingSpace
syn match TodoCheckboxOngoingSpace " " nextgroup=TodoCheckboxOngoingPriority contained
" Matches a priority. Spaces followed by periods followed by exclaimation followed by a space. If it doesn't
" match, it continues on to the description for the checkbox.
syn match TodoCheckboxOngoingPriority "\v( *\.*!* ){,1}" nextgroup=TodoCheckboxOngoingDesc contained
" This matches a multiline ongoing checkbox description. It starts right away with any char and ends
" at the beginning of the next checkbox or next group title. /me=e-1 means match to the end offset
" by one so that it doesn't include the first char of a title or the "[".
syn region TodoCheckboxOngoingDesc start="." end=/\v- \[/me=e-4 contained contains=TodoTag,TodoProject,TodoContext,TodoDueDate,TodoLeadingSpace,TodoComment,TodoStarted,TodoFinished,TodoDateTime

" This matches a checkbox like "- [~]"
syn region TodoCheckboxObsolete start=/\- \[\~/ms=s+2 end=/\v\]/me=e nextgroup=TodoCheckboxObsoleteSpace contains=TodoLeadingSpace
syn match TodoCheckboxObsoleteSpace " " nextgroup=TodoCheckboxObsoletePriority contained
" Matches a priority. Spaces followed by periods followed by exclaimation followed by a space. If it doesn't
" match, it continues on to the description for the checkbox.
syn match TodoCheckboxObsoletePriority "\v( *\.*!* ){,1}" nextgroup=TodoCheckboxObsoleteDesc contained
" This matches a multiline obsolete checkbox description. It starts right away with any char and ends
" at the beginning of the next checkbox or next group title. /me=e-1 means match to the end offset
" by one so that it doesn't include the first char of a title or the "[".
syn region TodoCheckboxObsoleteDesc start="." end=/\v- \[/me=e-4 contained contains=TodoTag,TodoProject,TodoContext,TodoDueDate,TodoLeadingSpace,TodoComment,TodoStarted,TodoFinished,TodoDateTime

" Matches a tag with letters, numbers, _, or -
syn match TodoTag "\v#[a-zA-Z0-9_-]+" contained
syn match TodoContext "\v\#[a-zA-Z0-9_-]+" contained
syn match TodoProject "\v\+[a-zA-Z0-9_-]+" contained

syntax match TodoStarted 'started:' contained contains=TodoDateTimeTodoDueDate
syntax match TodoFinished 'finished:' contained contains=TodoDateTimeTodoDueDate
syntax match TodoDueAt 'due:' contained contains=TodoDateTime,TodoDueDate
syntax match TodoStartDate 'start-date:' contained contains=TodoDateTime,TodoDueDate
syntax match TodoEndDate 'end-date:' contained contains=TodoDateTime,TodoDueDate

syn match TodoDueDate "\v\d{2}([-/]Q\d|[-/]W\d+|-\d{2}-\d{4}|/\d{4}/\d{2}|-\d{4}|/\d{2})?" contained
syntax match TodoDateTime '\d\{2,4\}-\d\{2\}-\d\{4\}-\d\{2\}:\d\{2\}' contained

syn match TodoComment '\ \{2,\}>\s.\+$' contained contains=TodoTag,TodoProject,TodoContext,TodoDueDate,TodoLeadingSpace,TodoDueAt,TodoStartDate,TodoEndDate

hi def link TodoCheckboxOpen Identifier
hi def link TodoCheckboxOpenPriority Type
hi def link TodoCheckboxOpenDesc NONE

hi def link TodoCheckboxChecked Boolean
hi def link TodoCheckboxCheckedPriority Comment
hi def link TodoCheckboxCheckedDesc Comment

hi def link TodoCheckboxOngoing WarningMsg
hi def link TodoCheckboxOngoingPriority Type
hi def link TodoCheckboxOngoingDesc NONE

hi def link TodoCheckboxObsolete Error
hi def link TodoCheckboxObsoletePriority Comment
hi def link TodoCheckboxObsoleteDesc Comment

hi def link TodoTag PreProc
hi def link TodoContext Label
hi def link TodoProject Title
hi def link TodoDueDate Number
hi def link TodoDateTime Number
hi def link TodoComment SpecialComment
highlight default link TodoStarted Label
highlight default link TodoFinished Label
highlight default link TodoDueAt Label
highlight default link TodoStartDate Label
highlight default link TodoEndDate Label

call matchadd('Conceal', '^\ \{4,\}```[a-z]\+$', 10, -1, {'conceal':' '})
call matchadd('Conceal', '^\ \{4,\}```$', 10, -1, {'conceal':' '})

let b:current_syntax = "todo"
