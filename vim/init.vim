" Functions {{{
function! init#search_docs(...)
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
set foldopen=block,hor,jump,mark,percent,quickfix,search,tag
set complete-=i
set noshowmode

set termguicolors
set nofoldenable
set colorcolumn=81

set completeopt-=preview
set splitbelow
set splitright

set signcolumn=yes

" Reduces the number of lines that are above the curser when I do zt.
set scrolloff=3

" Sets how many lines of history VIM has to remember
set history=500

" Show an arrow with a space for line breaks.
set showbreak=↳\ 

" Enable filetype plugins
filetype plugin on
filetype indent on

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
set nobackup
set nowb
set noswapfile

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
" }}}

" User Interface {{{

try
    set guifont=Cascadia\ Code:h10
catch
endtry

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

" Close the current buffer
map <leader>bd :Bclose<cr>

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

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
xnoremap p "_dP
xnoremap <leader>c "_c

" Mappings to [l]cd into the current file's directory.
command! Lcdc lcd %:p:h
command! Cdc cd %:p:h

" Return to last edit position when opening files (You want this!)
au BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$")
            \ | exe "normal! g'\"" | endif

" }}}

" Maps Commands {{{

nnoremap <leader>an :next<CR>
nnoremap <leader>ap :previous<CR>

nnoremap <leader>ln :lnext<CR>
nnoremap <leader>lp :lprevious<CR>

nnoremap <leader>cn :cnext<cr>
nnoremap <leader>cp :cprevious<cr>

nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>

map <leader>tn :tabnew<cr>
map <leader>tc :tabclose<cr>

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

nmap <silent> <leader>dh :call init#search_docs()<CR>
command! -nargs=1 Search :call init#search_docs(<f-args>)

" Taking from here: https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
" Allows running macros only on selected files.
function! init#execute_macro_on_visual_range()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
endfunction
xnoremap @ :<C-u>call init#execute_macro_on_visual_range()<CR>
" }}}

" Misc {{{
function! s:CreateCustomNvimListenServer()
    if has('win32')
        return
    endif

    let pid = string(getpid())
    let socket_name = expand('~/.dotfiles/vim/temp_dirs/servers/nvim') . pid . '.sock'
    call serverstart(socket_name)
endfunction

augroup StartUp
    autocmd!
    autocmd VimEnter * call s:CreateCustomNvimListenServer()
augroup END

" }}}

" Plugins {{{
" Pre-configuration {{{

" Disable netrw in favor of vim-dirvish
let loaded_netrwPlugin = 1

" Disable markdown support for polyglot because it messes up with syntax
" highlighting.
let g:polyglot_disabled = ['markdown']

let g:vimrc_rust_enabled = !empty($VIMRC_RUST_ENABLED)

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
    call minpac#add('autozimu/LanguageClient-neovim', {'branch': 'next'})
    call minpac#add('Shougo/deoplete.nvim', {'do': 'UpdateRemotePlugins'})

    call minpac#add('mcchrish/info-window.nvim')

    " On Demand Plugins {{{

    call minpac#add('neomake/neomake', {'type': 'opt'})
    call minpac#add('vim-scripts/SyntaxRange', {'type': 'opt'})
    call minpac#add('octol/vim-cpp-enhanced-highlight', {'type': 'opt'})

    call minpac#add('majutsushi/tagbar', {'type': 'opt'})
    call minpac#add('Vimjas/vim-python-pep8-indent', {'type': 'opt'})
    call minpac#add('masukomi/vim-markdown-folding', {'type': 'opt'})

    call minpac#add('metakirby5/codi.vim', {'type': 'opt'})

    call minpac#add('junegunn/goyo.vim', {'type': 'opt'})

    if has('win32') == 0
        call minpac#add('sakhnik/nvim-gdb', {'type': 'opt'})
    endif

    if g:vimrc_rust_enabled
        call minpac#add('rust-lang/rust.vim', {'type': 'opt'})
    endif

    " }}}
endfunction

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
imap <c-x><c-f> <plug>(fzf-complete-path)

let g:fzf_preview_window = ''
" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = "--graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color=always"

" }}}

" TagBar {{{

let g:tagbar_show_linenumbers = 1

map <leader>tb  :Tagbar<CR>
map <leader>tbs  :TagbarShowTag<CR>

" }}}

" Completion {{{

" Deoplete {{{

let g:deoplete#enable_at_startup = 1
augroup Doplete
    autocmd!
    " Enable auto complete only when the menu is visible. Otherwise it's just
    " annoying.
    autocmd TextChangedP * call deoplete#custom#option('auto_complete', v:true)
    autocmd CompleteDone * call deoplete#custom#option('auto_complete', v:false)
augroup END

" Pass a dictionary to set multiple options
autocmd VimEnter * call deoplete#custom#option({
            \   'smart_case': v:false,
            \   'auto_complete': v:false,
            \   'max_list': 100
            \ })

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other
" plugin.
function! init#check_backspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ init#check_backspace() ? "\<TAB>" :
            \ deoplete#manual_complete()
inoremap <silent> <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent> <expr><c-f> pumvisible() ? deoplete#manual_complete() : "\<C-f>"

" }}}

" Server Discovery {{{

let g:vimrc_cpp_servers = []
let g:vimrc_python_server = []
let g:vimrc_rust_server = []

if executable("ccls")
    call add(g:vimrc_cpp_servers, "ccls")
elseif executable("cquery")
    call add(g:vimrc_cpp_servers, "cquery")
elseif executable("clangd")
    call add(g:vimrc_cpp_servers, "clangd")
else
    echomsg "No C++ linter is found."
endif

if executable("pyls")
    call add(g:vimrc_python_server, "pyls")
else
    echomsg "No Python language server is found."
endif

if g:vimrc_rust_enabled
    if executable("rls")
        call add(g:vimrc_rust_server, "rls")
    elseif executable("rustup")
        let g:vimrc_rust_server = ["rustup", "run", "stable", "rls"]
    else
        echomsg "No Rust language server is found."
    endif
endif

" }}}

" NeoMake {{{

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

" }}}

" LanguageClient {{{

let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_serverCommands = {}
if len(g:vimrc_cpp_servers) > 0
    let g:LanguageClient_serverCommands["c"] = g:vimrc_cpp_servers
    let g:LanguageClient_serverCommands["cpp"] = g:vimrc_cpp_servers
endif

if len(g:vimrc_python_server) > 0
    let g:LanguageClient_serverCommands["python"] = g:vimrc_python_server
endif

if len(g:vimrc_rust_server) > 0
    let g:LanguageClient_serverCommands["rust"] = g:vimrc_rust_server
endif

command! Format :call Languagelacklient#textDocument_formatting()<CR>
command! RFormat :call LanguageClient#textDocument_rangeFormatting()<CR>
nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>

nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
vnoremap <leader>f :call LanguageClient#textDocument_rangeFormatting()<CR>
nnoremap <leader>f :call LanguageClient#textDocument_formatting()<CR>

nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>

nnoremap <leader>lh :call LanguageClient_textDocument_documentHighlight()<CR>
nnoremap <leader>lc :call LanguageClient#clearDocumentHighlight()<CR>

let g:LanguageClient_diagnosticsList = "Location"
let g:LanguageClient_selectionUI = "fzf"
let g:LanguageClient_useVirtualText = "No"


" }}}

" Preview {{{

function! init#show_loc_item_in_preview()
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

    for item in l:list
        if get(item, "lnum", "") == l:current_line
            let l:type = get(item, "type", "I")
            let l:type = get(l:type_mapping, l:type, "")
            let l:text = get(item, "text", "")
            call preview#show("Neomake", [l:type . ": " . l:text])
            break
        endif
    endfor
endfunction

nnoremap <silent> <leader>li :call init#show_loc_item_in_preview()<CR>

" }}}

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

autocmd VimEnter * colorscheme cosmic_latte
" }}}
