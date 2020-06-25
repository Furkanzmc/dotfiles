command! MarkScratch :call buffers#mark_scratch()

vmap <leader>s :call buffers#visual_selection('search', '')<CR>
" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call buffers#visual_selection('replace', '')<CR>

" Don't close window, when deleting a buffer
nmap <leader>bd :call buffers#close()<CR>
command! Bclose :call buffers#close()
command! -nargs=1 -bang Bdeletes :call buffers#wipe_matching('<args>', <q-bang>)
command! Bdhidden :call buffers#delete_hidden()
command! Bdnonexisting :call buffers#wipe_nonexisting_files()


autocmd BufWritePre *.py,*.cpp,*.qml,*.js,*.txt,*.json,*.html
            \ :call buffers#clean_extra_spaces()

" Code from https://www.vim.org/scripts/script.php?script_id=443
" Highlight trailing spaces, and tabs.
if !exists("g:vimrc_loaded_spacehi")
    let g:vimrc_loaded_spacehi = v:true

    if !exists("g:vimrc_spacehi_tab_color")
        let g:vimrc_spacehi_tab_color = "ctermfg=137 cterm=undercurl"
        let g:vimrc_spacehi_tab_color = g:vimrc_spacehi_tab_color . " guifg=#b28761 gui=undercurl"
    endif

    if !exists("g:spacehi_spacecolor")
        let g:spacehi_spacecolor = "ctermbg=196"
        let g:spacehi_spacecolor = g:spacehi_spacecolor . " guibg='#EB5A2D'"
    endif

    function! s:highlight_space()
        if &filetype == "" && !get(g:, "vimrc_spacehi_enabled_for_all", v:false)
            return
        endif

        if exists("b:space_highlighted") && b:space_highlighted == v:true
            return
        endif

        if &filetype == "help" || &filetype == "qf"
            let b:space_highlighted = v:true
            return
        endif

        syntax match spacehiTab /\t/ containedin=ALL
        execute("highlight spacehiTab " . g:vimrc_spacehi_tab_color)

        syntax match spacehiTrailingSpace /\s\+$/ containedin=ALL
        execute("highlight spacehiTrailingSpace " . g:spacehi_spacecolor)
        let b:space_highlighted = v:true
    endfunction

    function! s:clear_highlight()
        if &filetype == "" && !get(g:, "vimrc_spacehi_enabled_for_all", v:false)
            return
        endif

        if exists("b:space_highlighted") && b:space_highlighted == v:false
            return
        endif

        syntax match spacehiTab /\t/ containedin=ALL
        execute("highlight clear spacehiTab")

        syntax match spacehiTrailingSpace /\s\+$/ containedin=ALL
        execute("highlight clear spacehiTrailingSpace")

        let b:space_highlighted = v:false
    endfunction

    augroup vimrc_highlight
        autocmd!
        autocmd BufNewFile,BufReadPost,FilterReadPost,FileReadPost,Syntax,InsertLeave,BufEnter,BufWritePost
                    \ * call s:highlight_space()
    augroup END
endif
