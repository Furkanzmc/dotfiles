command! MarkScratch :call buffers#mark_scratch()

vmap <leader>s :call buffers#visual_selection('search', '')<CR>
" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call buffers#visual_selection('replace', '')<CR>

" Don't close window, when deleting a buffer
command! Bclose :call buffers#close()
command! -nargs=1 -bang Bdeletes :call buffers#wipe_matching('<args>', <q-bang>)
command! Bdhidden :call buffers#delete_hidden()


autocmd BufWritePre *.py,*.cpp,*.qml,*.js,*.txt,*.json
            \ :call buffers#clean_extra_spaces()

