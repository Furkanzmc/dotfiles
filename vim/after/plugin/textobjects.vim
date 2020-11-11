" URL text object.
xnoremap <silent> iu :<C-u>call textobjects#url_text_object()<CR>
onoremap iu :<C-u>normal viu<CR>

" Line text objects.
xnoremap il g_o^
onoremap il :<C-u>normal vil<CR>
