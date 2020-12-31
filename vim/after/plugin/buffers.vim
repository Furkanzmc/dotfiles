if !exists("g:vimrc_spacehi_enabled_filetypes")
    let g:vimrc_spacehi_enabled_filetypes = [
                \ "cpp",
                \ "diff",
                \ "fugitive",
                \ "git",
                \ "gitcommit",
                \ "html",
                \ "javascript",
                \ "json",
                \ "ps1",
                \ "python",
                \ "qmake",
                \ "qml",
                \ "rust",
                \ "todo",
                \ "vim",
                \ "vue",
                \ "yaml",
                \ ]
endif

" Code from https://www.vim.org/scripts/script.php?script_id=443
" Highlight trailing spaces, and tabs.
if exists("s:vimrc_loaded_spacehi")
    finish
endif

let s:vimrc_loaded_spacehi = v:true

if !exists("g:vimrc_spacehi_tab_color")
    let g:vimrc_spacehi_tab_color = "ctermfg=137 cterm=undercurl"
    let g:vimrc_spacehi_tab_color = g:vimrc_spacehi_tab_color . " guifg=#b28761 gui=undercurl"
endif

if !exists("g:spacehi_spacecolor")
    let g:spacehi_spacecolor = "ctermbg=196"
    let g:spacehi_spacecolor = g:spacehi_spacecolor . " guibg='#EB5A2D'"
endif

function! s:highlight_space()
    if index(g:vimrc_spacehi_enabled_filetypes, &filetype) == -1
        call s:clear_highlight()
        return
    endif

    if get(b:, "space_highlighted", v:false)
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
    if index(g:vimrc_spacehi_enabled_filetypes, &filetype) == -1
        return
    endif

    if !get(b:, "space_highlighted", v:false)
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
