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

" }}}

" General {{{

" Enable filetype plugins
filetype plugin on
filetype indent on

set foldopen=block,hor,jump,mark,percent,quickfix,search,tag
set complete=.,w,k
set noshowmode

set termguicolors
set nofoldenable
set colorcolumn=81

set completeopt=menuone,noinsert,noselect
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

set diffopt=vertical,filler
if has("nvim")
    set diffopt+=internal
endif

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

imap <c-t> <tab>
imap <c-d> <s-tab>

" Pressing <leader>ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

command! -nargs=1 StartTicket :let g:vimrc_active_jira_ticket=<f-args>
command! CloseTicket :if exists("g:vimrc_active_jira_ticket") | unlet g:vimrc_active_jira_ticket | endif

function s:glob_filter(start_line, end_line, matching, args)
  let l:bang = a:matching ? "!" : ""
  if a:start_line == a:end_line
    execute "%g" . l:bang . "/" . a:args . "/d"
  else
    execute a:start_line . "," . a:end_line . "g" . l:bang . "/" . a:args . "/d"
  end
endfunction

command! -buffer -bang -nargs=* -range FilterLines :call <SID>glob_filter(<line1>, <line2>, "<bang>" != "!", <q-args>)

" Taking from here: https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
" Allows running macros only on selected files.
function! s:execute_macro_on_visual_range()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
endfunction

xnoremap @ :<C-u>call <SID>execute_macro_on_visual_range()<CR>

command Time :echohl IncSearch | echo "Time: " . strftime('%b %d %A, %H:%M') | echohl NONE
" }}}

" Plugins {{{
" Pre-configuration {{{

" Disable netrw in favor of vim-dirvish
let loaded_netrwPlugin = 1

" Disable markdown support for polyglot because it messes up with syntax
" highlighting.
let g:polyglot_is_disabled = {'markdown': v:true, 'python-indent': v:true}

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
    call minpac#add('furkanzmc/nvim-http', {'do': 'UpdateRemotePlugins'})
    call minpac#add('tmsvg/pear-tree')
    call minpac#add('justinmk/vim-dirvish')
    call minpac#add('Furkanzmc/firvish.nvim')

    " On Demand Plugins {{{

    call minpac#add('neovim/nvim-lspconfig', {'type': 'opt'})
    call minpac#add('neomake/neomake', {'type': 'opt'})
    call minpac#add('vim-scripts/SyntaxRange', {'type': 'opt'})
    call minpac#add('majutsushi/tagbar', {'type': 'opt'})
    call minpac#add('masukomi/vim-markdown-folding', {'type': 'opt'})
    call minpac#add('metakirby5/codi.vim', {'type': 'opt'})
    call minpac#add('junegunn/goyo.vim', {'type': 'opt'})
    call minpac#add('sakhnik/nvim-gdb', {
                \ 'type': 'opt',
                \ 'do': 'UpdateRemotePlugins'
                \ })
    call minpac#add('rust-lang/rust.vim', {'type': 'opt'})
    call minpac#add('nvim-treesitter/nvim-treesitter', {'type': 'opt'})
    call minpac#add('mhartington/formatter.nvim', {'type': 'opt'})

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

" Neomake {{{

function s:setup_neomake()
    if exists("g:vimrc_is_neomake_loaded")
        return
    endif

    packadd neomake

    call neomake#configure#automake('rw')

    let g:vimrc_is_neomake_loaded = v:true
endfunction

augroup neomake_ft
    au!
    autocmd FileType python,qml,cpp,rust :call <SID>setup_neomake()
augroup END

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
    autocmd!
    autocmd User NeomakeJobFinished
                \ nested call <SID>neomake_job_finished()
augroup END

" }}}

" Completion {{{

" nvim-lsp {{{

" These are here so I remember to configure it when Neovim LSP supports it. {{{

let g:vimrc_lsp_virtual_text_prefix_error = '✖'
let g:vimrc_lsp_virtual_text_prefix_warning = '‼'
let g:vimrc_lsp_virtual_text_prefix_information = 'ℹ'
let g:vimrc_lsp_virtual_text_prefix_hint = '⦿'
let g:vimrc_lsp_virtual_text_include_error_message = 0

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
        packadd nvim-lspconfig
        let s:completion_plugins_loaded = v:true
    endif

    if luaeval("require'lsp'.is_lsp_running(" . bufnr() . ")")
        return
    endif

    execute "lua require'lsp'.setup_lsp" . '("' . a:file_type . '")'
endfunction

function s:setup_completion()
    if &l:filetype == "dirvish" || &l:modifiable == 0
        return
    endif

    if !exists("b:is_completion_configured")
        let b:is_completion_configured = v:false
    endif

    execute "lua require'completion'.setup_completion()"
endfunction

command! PrintCurrentLSP :lua require'lsp'.print_buffer_clients(vim.api.nvim_get_current_buf())<CR>
command! StopCurrentLSP :lua require'lsp'.stop_buffer_clients()<CR>

augroup lsp_completion
    au!

    autocmd BufEnter * call <SID>setup_completion()
    autocmd FileType * call <SID>setup_completion()

    autocmd BufEnter,WinEnter *.py,*.cpp,*.c,*.h,*.vim,*.json,*.rs,*.java call <SID>setup_lsp(&l:filetype)
    autocmd FileType python,cpp,json,vim,rust,java call <SID>setup_lsp(&l:filetype)
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

" nvim-treesitter {{{

function s:setup_treesitter()
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
                \ | setlocal foldmethod=expr
                \ | setlocal foldexpr=nvim_treesitter#foldexpr()
                \ | endif
augroup END

" }}}

" codi {{{

let g:codi#virtual_text=0

" }}}

" format.nvim {{{

function s:setup_format_nvim()
lua << EOF
    require('format').setup({
      javascript = {
          prettier = function()
            return {
              exe = "prettier",
              args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
              stdin = true
            }
          end
      },
      python = {
          black = function()
            return {
              exe = "black",
              args = {"--quiet","-"},
              stdin = true
            }
          end
      },
      cpp = {
          clang_format = function()
            return {
              exe = "clang-format",
              args = {"-i"},
              stdin = true
            }
          end
      },
      qml = {
          qmlformat = function()
            return {
              exe = "qmlformat",
              args = {"-i"},
              stdin = true
            }
          end
      },
    })
EOF
endfunction

augroup plugin_format_nvim
    au!
    au FileType vim,javascript,python,cpp,qml
                \   if !exists(":Format")
                \ |     packadd formatter.nvim
                \ |     call <SID>setup_format_nvim()
                \ | endif
                \ | nmap <buffer> <silent> gq :Format<CR>
augroup END

" }}}

" firvish.nvim {{{

let g:firvish_shell = "pwsh"

" }}}

" }}}

augroup vimrc_init
    autocmd!
    autocmd BufRead,BufEnter,FileType * call <SID>load_dictionary()
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false, higroup="IncSearch", timeout=100}
    autocmd VimEnter * call s:create_custom_nvim_server()
    autocmd VimEnter * colorscheme cosmic_latte
    " Return to last edit position when opening files (You want this!)
    au BufReadPost *
                \ if line("'\"") > 1 && line("'\"") <= line("$")
                \ | exe "normal! g'\"" | endif
augroup END
