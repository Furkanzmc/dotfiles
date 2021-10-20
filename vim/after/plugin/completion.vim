if get(g:, "g:vimrc_completion_plugin_loaded", v:false)
    finish
endif

function! s:is_previous_character_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

function! s:is_previous_character_abbvr_char() abort
    let col = col('.') - 1
    return col && getline('.')[col - 1]  =~ '@'
endfunction

function completion#completion_wrapper()
    lua require'vimrc.completion'.trigger_completion()
    return ''
endfunction

function s:trigger_completion()
    return "\<c-r>=completion#completion_wrapper()\<CR>"
endfunction

imap <silent><expr> <C-n>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>is_previous_character_abbvr_char() ? "\<C-]>" :
            \ <SID>is_previous_character_space() ? "\<TAB>" : <SID>trigger_completion()

imap <silent><expr> <C-p>
            \ pumvisible() ? "\<C-p>" :
            \ <SID>is_previous_character_space() ? "\<S-TAB>" : <SID>trigger_completion()

let g:vimrc_completion_plugin_loaded = v:true
