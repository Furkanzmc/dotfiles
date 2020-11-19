" Functions {{{

function! s:create_custom_nvim_server()
    let pid = string(getpid())
    if has("win32")
        let socket_name = '\\.\pipe\nvim-' . pid
    else
        let socket_name = expand('~/.dotfiles/vim/temp_dirs/servers/nvim') . pid . '.sock'
    endif

    call serverstart(socket_name)
endfunction

function! s:load_dictionary()
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

" Taking from here: https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
" Allows running macros only on selected files.
function! s:execute_macro_on_visual_range()
    echo "@".getcmdline()
    execute ":'<,'>normal @" . nr2char(getchar())
endfunction


" }}}

" General {{{

" Enable filetype plugins
filetype plugin on
filetype indent on

set foldopen=block,hor,jump,mark,percent,quickfix,search,tag
set complete=.,w,k,kspell,b
set completeopt=menuone,noinsert,noselect

set termguicolors
set nofoldenable
set colorcolumn=81

set noshowmode
set shortmess+=c
set splitbelow

set splitright
set signcolumn=no
set pumheight=12

" Reduces the number of lines that are above the curser when I do zt.
set scrolloff=3

" Sets how many lines of history VIM has to remember
set history=500

" Show an arrow with a space for line breaks.
set showbreak=↳\ 

set inccommand=split
set clipboard=unnamed

" Set to auto read when a file is changed from the outside
set autoread

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

" Means that you can undo even when you close a buffer/VIM
set undodir=~/.dotfiles/vim/temp_dirs/undodir
set undofile

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
set foldtext=fold#fold_text()

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
else
    set background=light
endif

set diffopt=vertical,filler,context:5,closeoff,algorithm:histogram,internal

set langmenu=en
set number
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
set hidden

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
set matchtime=3

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

" Use Unix a the standard file type
set ffs=unix,dos,mac

" }}}

" }}}

" Moving around, tabs, windows and buffers {{{

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Specify the behavior when switching between buffers
" Use the current tab for openning files from quickfix.
" Otherwise it gets really annoying and each file is opened
" in a different tab.
set switchbuf=useopen,usetab
set stal=2

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

imap <c-t> <tab>
imap <c-d> <s-tab>

xnoremap @ :<C-u>call <SID>execute_macro_on_visual_range()<CR>

" Pressing <leader>ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

command! -nargs=1 StartTicket :let g:vimrc_active_jira_ticket=<f-args>
command! CloseTicket :if exists("g:vimrc_active_jira_ticket") | unlet g:vimrc_active_jira_ticket | endif
command! -nargs=? JiraOpenTicket :call jira#open_ticket(<f-args>)
command! -nargs=? JiraOpenTicketJson :call jira#open_ticket_in_json(<f-args>)

command Time :echohl IncSearch | echo "Time: " . strftime('%b %d %A, %H:%M') | echohl NONE


" }}}

" Plugins {{{
" Pre-configuration {{{

" Disable netrw in favor of vim-dirvish
let loaded_netrwPlugin = 1

" Disable markdown support for polyglot because it messes up with syntax
" highlighting.
let g:polyglot_is_disabled = {
            \ 'markdown': v:true,
            \ 'json': v:true,
            \ 'vue': v:true,
            \ 'sensible': v:true,
            \ }

" }}}

" minpack {{{

function! PackInit()
    packadd minpac

    call minpac#init()

    call minpac#add('sheerun/vim-polyglot')
    call minpac#add('tpope/vim-commentary')
    call minpac#add('tpope/vim-fugitive')
    call minpac#add('machakann/vim-sandwich')
    call minpac#add('furkanzmc/cosmic_latte')
    call minpac#add('tmsvg/pear-tree')
    call minpac#add('justinmk/vim-dirvish')
    call minpac#add('Furkanzmc/firvish.nvim')
    call minpac#add('neovim/nvim-lspconfig')

    " On Demand Plugins {{{

    call minpac#add('neomake/neomake', {'type': 'opt'})
    call minpac#add('vim-scripts/SyntaxRange', {'type': 'opt'})
    call minpac#add('majutsushi/tagbar', {'type': 'opt'})
    call minpac#add('masukomi/vim-markdown-folding', {'type': 'opt'})
    call minpac#add('junegunn/goyo.vim', {'type': 'opt'})
    call minpac#add('sakhnik/nvim-gdb', {
                \ 'type': 'opt',
                \ 'do': 'UpdateRemotePlugins'
                \ })
    call minpac#add('rust-lang/rust.vim', {'type': 'opt'})
    call minpac#add('nvim-treesitter/nvim-treesitter', {'type': 'opt'})
    call minpac#add('furkanzmc/nvim-http', {'type': 'opt', 'do': 'UpdateRemotePlugins'})

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

" TagBar {{{

let g:tagbar_show_linenumbers = 1

" }}}

" nvim-lsp {{{

" These are here so I remember to configure it when Neovim LSP supports it. {{{

let g:vimrc_lsp_virtual_text_prefix_error = '✖'
let g:vimrc_lsp_virtual_text_prefix_warning = '‼'
let g:vimrc_lsp_virtual_text_prefix_information = 'ℹ'
let g:vimrc_lsp_virtual_text_prefix_hint = '⦿'
let g:vimrc_lsp_virtual_text_include_error_message = 0

" }}}

sign define LspDiagnosticsSignError text=✖ texthl=LspDiagnosticsDefaultError
            \ linehl= numhl=
sign define LspDiagnosticsSignWarning text=‼ texthl=LspDiagnosticsDefaultWarning
            \ linehl= numhl=
sign define LspDiagnosticsSignInformation text=ℹ
            \ texthl=LspDiagnosticsDefaultInformation linehl= numhl=
sign define LspDiagnosticsSignHint text=⦿ texthl=LspDiagnosticsDefaultHint
            \ linehl= numhl=

lua << EOF
    require'lsp'.setup_lsp()
EOF

function s:setup_completion()
    if &l:filetype == "dirvish" || &l:modifiable == 0
        return
    endif

lua << EOF
    require'completion'.setup_completion()
EOF
endfunction

augroup vimrc_completion
    au!

    autocmd BufEnter,FileType * call <SID>setup_completion()
augroup END

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

function init#completion_wrapper()
    lua require'completion'.trigger_completion()
    return ''
endfunction

function s:trigger_completion()
    return "\<c-r>=init#completion_wrapper()\<CR>"
endfunction

inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" : <SID>trigger_completion()

inoremap <silent><expr> <S-TAB>
            \ pumvisible() ? "\<C-p>" :
            \ <SID>check_back_space() ? "\<S-TAB>" : <SID>trigger_completion()

" }}}

" Preview {{{

nnoremap <silent> sli :call quickfix#show_item_in_preview(v:true, line('.'))<CR>
nnoremap <silent> sci :call quickfix#show_item_in_preview(v:false, line('.'))<CR>

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

" nvim-treesitter {{{

function s:setup_treesitter()
    setlocal foldmethod=expr
    setlocal foldexpr=nvim_treesitter#foldexpr()

lua << EOF
    require'nvim-treesitter.configs'.setup {
      ensure_installed = {'python', 'html', 'cpp', 'vue', 'json'},
      highlight = {
        enable = true
      },
      refactor = {
          highlight_definitions = {
              enable = true,
          },
      },
    }
EOF
endfunction

augroup plugin_nvim_treesitter
    au!
    au FileType python,cpp,json,javascript,html,vue
                \ if !exists(":TSInstall")
                \ | packadd nvim-treesitter
                \ | call <SID>setup_treesitter()
                \ | endif
augroup END

" }}}

" codi {{{

let g:codi#virtual_text=0

" }}}

" firvish.nvim {{{

let g:firvish_shell = "pwsh"

" }}}

" }}}

augroup vimrc_init
    autocmd!
    autocmd BufRead,BufEnter,FileType * call <SID>load_dictionary()
    autocmd BufReadPre,FileReadPre *.http :if !exists("g:nvim_http_preserve_responses")
                \ | packadd nvim-http
                \ | endif
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{
                \ on_visual=false, higroup="IncSearch", timeout=100}
    autocmd VimEnter * call s:create_custom_nvim_server()
    autocmd VimEnter * colorscheme cosmic_latte
    " Return to last edit position when opening files (You want this!)
    au BufReadPost *
                \ if line("'\"") > 1 && line("'\"") <= line("$")
                \ | execute "normal! g'\""
                \ | endif
augroup END
