" Functions {{{
function! s:search_docs(...)
    let wordUnderCursor = a:0 > 0 ? a:1 : expand('<cword>')
    let filetype = &filetype
    if (filetype == 'qml')
        let helpLink = 'doc.qt.io'
        " Add QML suffix to improve the search. Sometimes we may hit reults
        " for C++ class with the same name.
        let wordUnderCursor .= ' QML'
    elseif (filetype == 'vim')
        execute 'help ' . wordUnderCursor
        return
    elseif (filetype == 'cpp')
        let helpLink = match(wordUnderCursor, 'Q') == 0 ? 'doc.qt.io' : 'en.cppreference.com'
    elseif (filetype == 'python')
        let helpLink = 'docs.python.org/3/'
    elseif (filetype == 'javascript')
        let helpLink = 'developer.mozilla.org/en-US/docs/Web/JavaScript/Reference'
    elseif (filetype == 'ps1')
        let helpLink = 'https://docs.microsoft.com/en-us/powershell/'
    else
        let helpLink = ''
    endif

    if (len(helpLink) > 0)
        let searchLink = 'https://duckduckgo.com/?q=\' . wordUnderCursor .  ' site:' . helpLink
    else
        let searchLink = 'https://duckduckgo.com/?q=' . wordUnderCursor
    endif

    if has('win32')
        call execute('!explorer "' . searchLink . '"')
    else
        call execute('!open "' . searchLink . '"')
    endif
endfunction
" }}}

" General {{{
" which commands trigger auto-unfold

" Enable filetype plugins
filetype plugin on
filetype indent on

set foldopen=block,hor,jump,mark,percent,quickfix,search,tag
set complete=.,w,b,u,t,k
set noshowmode

set termguicolors
set nofoldenable
set colorcolumn=81

set completeopt=menuone,noinsert,noselect
set shortmess+=c
set splitbelow

set splitright
set signcolumn=no

" Reduces the number of lines that are above the curser when I do zt.
set scrolloff=3

" Sets how many lines of history VIM has to remember
set history=500

" Show an arrow with a space for line breaks.
set showbreak=↳\ 

set inccommand=split

" Access system clipboard on macOS.
set clipboard=unnamed

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ' '
let maplocalleader = ' '

" Enable project specific settings
set exrc

" Use ripgrep over grep, if possible
if executable("rg")
   " Use rg over grep
   set grepprg=rg\ --vimgrep\ $*
   set grepformat=%f:%l:%c:%m
endif

try
    " Means that you can undo even when you close a buffer/VIM
    set undodir=~/.dotfiles/vim/temp_dirs/undodir
    set undofile
catch
endtry

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set noswapfile

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

set linebreak
set textwidth=500

set autoindent
set smartindent

if executable("pwsh") && exists("$VIMRC_PWSH_ENABLED")
    set shell=pwsh
    set shellquote=
    set shellpipe=\|\ Out-File\ -Encoding\ UTF8
    set shellxquote=
    set shellcmdflag=-NoLogo\ -NonInteractive\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
    set shellredir=\|\ Out-File\ -Encoding\ UTF8\ %s\ \|\ Out-Null
endif
" }}}

" User Interface {{{

" Always show the status line
set laststatus=2
set tabline=%!tabline#config()

if $VIMRC_BACKGROUND == "dark"
    set background=dark
elseif $VIMRC_BACKGROUND == "light"
    set background=light
else
    set background=dark
endif

" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

set diffopt=vertical,filler
if has("nvim")
    set diffopt+=internal
endif

" Avoid garbled characters in Chinese language windows OS
let $LANG='en'
set langmenu=en

set nu
set relativenumber

" Turn on the Wild menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.qmlc,*jsc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
   set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif
set wildignorecase

"Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=3

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=300

" Disable scrollbars (real hackers don't use scrollbars for navigation!)
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L


" Colors and Fonts {{{

" Enable syntax highlighting
syntax enable

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" }}}

" }}}

" Moving around, tabs, windows and buffers {{{

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Specify the behavior when switching between buffers
try
  " Use the current tab for openning files from quickfix.
  " Otherwise it gets really annoying and each file is opened
  " in a different tab.
  set switchbuf=useopen,usetab
  set stal=2
catch
endtry

" Use these to delete a line without cutting it.
nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>c "_c

" Jump to the previous git conflict start
nnoremap <silent> [cs :call search('^<\{4,\} \w\+.*$', 'Wb')<CR>
" Jump to the previous git conflict end
nnoremap <silent> [ce :call search('^>\{4,\} \w\+.*$', 'Wb')<CR>

" Jump to the next git conflict start
nnoremap <silent> ]cs :call search('^<\{4,\} \w\+.*$', 'W')<CR>
" Jump to the next git conflict end
nnoremap <silent> ]ce :call search('^>\{4,\} \w\+.*$', 'W')<CR>

" Jump to previous divider
nnoremap <silent> [cm :call search('^=\{4,\}$', 'Wb')<CR>
" Jump to next divider
nnoremap <silent> ]cm :call search('^=\{4,\}$', 'W')<CR>

function s:count_conflicts()
    try
        redir => conflict_count
        silent execute '%s/^<\{4,\} \w\+.*$//gn'
        redir END
        let l:result = matchstr(conflict_count, '\d\+')
    catch
        let l:result = 0
    endtry

    echohl IncSearch
    echo " " . l:result . " merge conflicts"
    echohl Normal
endfunction
nnoremap <silent> =cc :call <SID>count_conflicts()<CR>

" }}}

" Maps, Commands {{{

nnoremap <silent> ]a <cmd>execute ":" . v:count . "next"<CR>
nnoremap <silent> [a <cmd>execute ":" . v:count . "previous"<CR>

nnoremap <silent> ]l <cmd>execute ":" . v:count . "lnext"<CR>
nnoremap <silent> [l <cmd>execute ":" . v:count . "lprevious"<CR>

nnoremap <silent> ]q <cmd>execute ":" . v:count . "cnext"<CR>
nnoremap <silent> [q <cmd>execute ":" . v:count . "cprevious"<CR>

nnoremap <silent> ]b <cmd>execute ":" . v:count . "bnext"<CR>
nnoremap <silent> [b <cmd>execute ":" . v:count . "bprevious"<CR>

" Remap VIM 0 to first non-blank character
map 0 ^

" Reselect text that was just pasted with ,v
nnoremap <leader>v V`]

" Move a line of text using ALT+[jk] or Command+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif

" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

nmap <silent> <leader>dh :call <SID>search_docs()<CR>
command! -nargs=1 Search :call <SID>search_docs(<f-args>)

command! -nargs=1 StartTicket :let g:vimrc_active_jira_ticket=<f-args>
command! CloseTicket :call if exists("g:vimrc_active_jira_ticket") | unlet g:vimrc_active_jira_ticket | endif

" Taking from here: https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
" Allows running macros only on selected files.
function! s:execute_macro_on_visual_range()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
endfunction

xnoremap @ :<C-u>call <SID>execute_macro_on_visual_range()<CR>


augroup LuaHighlight
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false, higroup="IncSearch", timeout=100}
augroup END
" }}}

" Misc {{{

" Custom Server {{{

function! s:create_custom_nvim_server()
    let pid = string(getpid())
    if has("win32")
        let socket_name = '\\.\pipe\nvim-' . pid
    else
        let socket_name = expand('~/.dotfiles/vim/temp_dirs/servers/nvim') . pid . '.sock'
    endif

    call serverstart(socket_name)
endfunction

augroup vimrc_startup
    autocmd!
    autocmd VimEnter * call s:create_custom_nvim_server()
augroup END

" }}}

" Dictionary {{{

function s:load_dictionary()
    if get(b:, "vimrc_dictionary_loaded", v:false)
        return
    endif

    let l:search_directories = get(
                \ g:, "vimrc_dictionary_paths", [])
    call add(l:search_directories, "~/.dotfiles/vim/dictionary/")

    let l:files = globpath(
                \ expand(join(l:search_directories, ",")),
                \ '\(' . &l:filetype . '_*\|' . &l:filetype . '\).dictionary')
    let l:files = split(l:files, '\n')
    if empty(l:files)
        return
    endif

    for file_path in l:files
        execute "setlocal dictionary+=" . file_path
    endfor

    let b:vimrc_dictionary_loaded = v:true
endfunction

augroup vimrc_dictionary
    autocmd!
    autocmd BufRead,BufEnter,FileType * call <SID>load_dictionary()
augroup END

" }}}

" }}}

" Plugins {{{
" Pre-configuration {{{

" Disable netrw in favor of vim-dirvish
let loaded_netrwPlugin = 1

" Disable markdown support for polyglot because it messes up with syntax
" highlighting.
let g:polyglot_disabled = ['markdown']

" }}}

" minpack {{{
function! PackInit()
    packadd minpac

    call minpac#init()

    call minpac#add('sheerun/vim-polyglot')
    call minpac#add('tpope/vim-commentary')
    call minpac#add('tpope/vim-fugitive')

    call minpac#add('machakann/vim-sandwich')
    call minpac#add('junegunn/fzf.vim')
    call minpac#add('junegunn/fzf')

    call minpac#add('furkanzmc/cosmic_latte')
    call minpac#add('furkanzmc/nvim-http', {'do': 'UpdateRemotePlugins'})
    call minpac#add('tmsvg/pear-tree')

    call minpac#add('justinmk/vim-dirvish')
    call minpac#add('mcchrish/info-window.nvim')

    " On Demand Plugins {{{

    call minpac#add('neovim/nvim-lsp', {'type': 'opt'})
    call minpac#add('neomake/neomake', {'type': 'opt'})

    call minpac#add('vim-scripts/SyntaxRange', {'type': 'opt'})
    call minpac#add('octol/vim-cpp-enhanced-highlight', {'type': 'opt'})
    call minpac#add('majutsushi/tagbar', {'type': 'opt'})

    call minpac#add('Vimjas/vim-python-pep8-indent', {'type': 'opt'})
    call minpac#add('masukomi/vim-markdown-folding', {'type': 'opt'})
    call minpac#add('metakirby5/codi.vim', {'type': 'opt'})

    call minpac#add('junegunn/goyo.vim', {'type': 'opt'})
    call minpac#add('sakhnik/nvim-gdb', {
                \ 'type': 'opt',
                \ 'do': 'UpdateRemotePlugins'
                \ })
    call minpac#add('rust-lang/rust.vim', {'type': 'opt'})

    " }}}
endfunction

packadd matchit
if exists('*minpac#init')
    call PackInit()
endif

command! PackUpdate call PackInit() | call minpac#update('', {'do': 'call minpac#status()'})
command! PackClean  call PackInit() | call minpac#clean()
command! PackStatus call PackInit() | call minpac#status()

" }}}

" vim-cpp-enhanced-highlight {{{

let g:cpp_member_variable_highlight = 1

" }}}

" fzf {{{

map <leader>o :Files<cr>
map <leader>b :Buffers<cr>
nmap <leader>s :Rg<cr>
map <leader>h :History<CR>

let g:fzf_preview_window = ''

" }}}

" TagBar {{{

let g:tagbar_show_linenumbers = 1

" }}}

" Neomake {{{

function s:setup_neomake()
    if exists("g:vimrc_is_neomake_loaded")
        return
    endif

    packadd neomake

    call neomake#configure#automake('rw')

    let g:vimrc_is_neomake_loaded = v:true
endfunction

let g:neomake_virtualtext_current_error = v:false

" Python {{{

let g:neomake_python_enabled_makers = ["pylint"]

" }}}

" QML {{{

let g:neomake_qml_qmllint_maker = {
    \ 'exe': 'qmllint',
    \ 'args': ["--check-unqualified"],
    \ 'errorformat': '%f:%l : %m',
    \ }

let g:neomake_qml_enabled_makers = ["qmllint"]

" }}}

autocmd FileType python,qml,cpp,rust :call <SID>setup_neomake()

function! s:neomake_job_finished() abort
    let l:context = g:neomake_hook_context
    if l:context.jobinfo.file_mode == 1
        return
    endif

    let l:current_time = strftime("%H:%M")
    let l:message = "Finished with " . l:context.jobinfo.exit_code .
                \ " at " . l:current_time
    echohl IncSearch
    echo l:message
    echohl Normal

    call setqflist(
                \ [],
                \ "a",
                \ {"lines": [l:message]})
endfunction

augroup neomake_hooks
    au!
    autocmd User NeomakeJobFinished
                \ nested call <SID>neomake_job_finished()
augroup END


" }}}

" Completion {{{

set pumheight=12

" nvim-lsp {{{

let g:lsp_location_list_enabled = 1
let g:lsp_virtual_text_enabled = 1
let g:lsp_signs_enabled = 1
" These are here so I remember to configure it when Neovim LSP supports it. {{{
let g:lsp_virtual_text_prefix_error = '✖'
let g:lsp_virtual_text_prefix_warning = '‼'
let g:lsp_virtual_text_prefix_information = 'ℹ'
let g:lsp_virtual_text_prefix_hint = '⦿'
let g:lsp_virtual_text_include_error_message = 0
" }}}

sign define LspDiagnosticsErrorSign text=✖ texthl=LspDiagnosticsError
            \ linehl= numhl=
sign define LspDiagnosticsWarningSign text=‼ texthl=LspDiagnosticsWarning
            \ linehl= numhl=
sign define LspDiagnosticsInformationSign text=ℹ
            \ texthl=LspDiagnosticsInformation linehl= numhl=
sign define LspDiagnosticsHintSign text=⦿ texthl=LspDiagnosticsHint
            \ linehl= numhl=

function! s:setup_lsp(file_type)
    if !exists('s:completion_plugins_loaded')
        packadd SyntaxRange
        packadd nvim-lsp
        let s:completion_plugins_loaded = v:true
    endif

    setlocal formatexpr=lua\ vim.lsp.buf.formatting()
    setlocal omnifunc=v:lua.vim.lsp.omnifunc

    if luaeval("require'lsp'.is_lsp_running()")
        return
    endif

    if !exists("b:is_lsp_shortcuts_set")
        let b:is_lsp_shortcuts_set = v:false
    endif

    execute "lua require'lsp'.setup_lsp" . '("' . a:file_type . '")'
endfunction

command! PrintCurrentLSP :lua require'lsp'.print_buffer_clients()<CR>
command! StopCurrentLSP :lua require'lsp'.stop_buffer_clients()<CR>

autocmd BufEnter *.py call <SID>setup_lsp("python")
autocmd FileType python call <SID>setup_lsp("python")

autocmd BufEnter *.cpp,*.c,*.h call <SID>setup_lsp("cpp")
autocmd FileType cpp call <SID>setup_lsp("cpp")

autocmd BufEnter *.json call <SID>setup_lsp("json")
autocmd FileType json call <SID>setup_lsp("json")

autocmd BufEnter *.vim call <SID>setup_lsp("vim")
autocmd FileType vim call <SID>setup_lsp("vim")

autocmd BufEnter *.rs call <SID>setup_lsp("rust")
autocmd FileType rust call <SID>setup_lsp("rust")

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ luaeval("require'lsp'.is_lsp_running()") == 0 ? "\<C-x><C-n>" : "\<C-x><C-o>"

inoremap <silent><expr> <S-TAB>
            \ pumvisible() ? "\<C-p>" :
            \ <SID>check_back_space() ? "\<S-TAB>" :
            \ luaeval("require'lsp'.is_lsp_running()") == 0 ? "\<C-x><C-p>" : "\<C-x><C-o>"

" }}}

" Preview {{{

function! s:show_loc_item_in_preview()
    let l:loclist = getloclist(winnr())
    let l:list = []

    if len(l:loclist) == 0
        let l:qflist = getqflist()
        let l:list = l:qflist
    else
        let l:list = l:loclist
    endif

    let l:current_line = line('.')
    let l:type_mapping = {
                \ "E": "Error",
                \ "W": "Warning",
                \ "I": "Info",
                \ }

    let l:lines = []
    for item in l:list
        if get(item, "lnum", "") == l:current_line
            let l:type = get(item, "type", "I")
            let l:type = get(l:type_mapping, l:type, "")
            let l:text = get(item, "text", "")
            call add(l:lines, l:type . ": " . l:text)
        endif
    endfor

    if len(l:lines) > 0
        call preview#show("Neomake", l:lines)
    endif
endfunction

nnoremap <silent> <leader>li :call <SID>show_loc_item_in_preview()<CR>

" }}}

" }}}

" nvim-gdb {{{

let g:nvimgdb_config_override = {
            \ "key_step": "<leader>s",
            \ "key_frameup": "<leader>u",
            \ "key_framedown": "<leader>d",
            \ "key_continue":   "<leader>c",
            \ "key_next":       "<leader>n",
            \ }

" }}}

" information-window {{{

function! init#show_file_info(default_lines)
    let currentTime = strftime('%b %d %A, %H:%M')
    let l:lines = [
        \ "",
        \ " [" . currentTime . "] ",
        \ " Line: " . line('.') . ":" . col('.'),
        \ ]

    if len(&filetype) > 0
        let fileTypeStr = " File: " . &filetype . ' - ' . &fileencoding .
                    \ ' [' . &fileformat . '] '

        call insert(l:lines, fileTypeStr, 2)
    endif

    let l:vimrc_info_window_lines_functions = get(g:,
                \ "vimrc_info_window_lines_functions", [])
    if len(l:vimrc_info_window_lines_functions) > 0
        for F in l:vimrc_info_window_lines_functions
            let l:custom_lines = F()
            for line in l:custom_lines
                call add(l:lines, line)
            endfor
        endfor
    endif

    call add(l:lines, "")
    return l:lines
endfunction

nmap <silent> <leader>i :call infowindow#create(
            \ {}, function("init#show_file_info"))<CR>

" }}}

" Return to last edit position when opening files (You want this!)
augroup vimrc_init
    au!
    autocmd VimEnter * colorscheme cosmic_latte
    au BufReadPost *
                \ if line("'\"") > 1 && line("'\"") <= line("$")
                \ | exe "normal! g'\"" | endif
augroup END
" }}}
