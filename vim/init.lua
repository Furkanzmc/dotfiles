local vim = vim
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g

-- Functions {{{

local function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function execute_macro_on_visual_range()
    cmd [[echo "@".getcmdline()]]
    cmd [[execute ":'<,'>normal @" . nr2char(getchar())]]
end

-- }}}

-- General {{{

cmd [[filetype plugin on]]
cmd [[filetype indent on]]

cmd("set runtimepath+=" .. fn.expand("~/.dotfiles/vim"))
cmd("set runtimepath+=" .. fn.expand("~/.dotfiles/vim/after"))

vim.o.foldopen = "block,hor,jump,mark,percent,quickfix,search,tag"
vim.o.complete = ".,w,k,kspell,b"
vim.o.completeopt = "menuone,noselect"

vim.o.termguicolors = true
vim.o.foldenable = false
vim.wo.colorcolumn = "81"

vim.o.showmode = false
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.splitbelow = true

vim.o.splitright = true
vim.wo.signcolumn = "no"
vim.o.pumheight = 12

vim.o.exrc = true
vim.o.shiftround = true

-- Reduces the number of lines that are above the curser when I do zt.
vim.o.scrolloff = 3

-- Sets how many lines of history VIM has to remember
vim.o.history = 500

-- Show an arrow with a space for line breaks.
vim.o.showbreak = "↳ "

vim.o.inccommand = "split"
vim.o.clipboard = "unnamed"

-- Set to auto read when a file is changed from the outside
vim.o.autoread = true

g.mapleader = " "
g.maplocalleader = " "

-- Use ripgrep over grep, if possible
if fn.executable("rg") then
    vim.o.grepprg = "rg --vimgrep $*"
    vim.o.grepformat = "%f:%l:%c:%m"
end

-- Means that you can undo even when you close a buffer/VIM
vim.o.undodir = fn.expand("~/.dotfiles/vim/temp_dirs/undodir")
vim.o.undofile = true

-- Turn backup off, since most stuff is in SVN, git et.c anyway...
vim.o.swapfile = false

-- Use spaces instead of tabs
vim.o.expandtab = true

-- Be smart when using tabs ;)
vim.o.smarttab = true

-- 1 tab == 4 spaces
vim.o.shiftwidth = 4
vim.o.tabstop = 4

vim.o.linebreak = true
vim.o.textwidth = 500

vim.o.autoindent = true
vim.o.smartindent = true

vim.o.foldtext = "fold#fold_text()"

if fn.executable("pwsh") == 1 and fn.exists("$VIMRC_PWSH_ENABLED") == 1 then
    vim.o.shell = "pwsh"
    vim.o.shellquote = ""
    vim.o.shellpipe = "| Out-File -Encoding UTF8"
    vim.o.shellxquote = ""
    vim.o.shellcmdflag =
        "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command"
    vim.o.shellredir = "| Out-File -Encoding UTF8 %s | Out-Null"
end

-- Specify the behavior when switching between buffers
-- Use the current tab for openning files from quickfix.
-- Otherwise it gets really annoying and each file is opened
-- in a different tab.
vim.o.switchbuf = "useopen,usetab"
vim.o.stal = 2

-- }}}

-- User Interface {{{

-- Always show the status line
vim.o.laststatus = 2

vim.o.tabline = "%!tabline#config()"

-- TODO: Using fn.expand is too flow here.
cmd [[
if $VIMRC_BACKGROUND == "dark"
    set background=dark
else
    set background=light
endif
]]

vim.o.diffopt =
    "vertical,filler,context:5,closeoff,algorithm:histogram,internal"

vim.o.langmenu = "en"
vim.wo.number = true
vim.wo.relativenumber = true

-- Turn on the Wild menu
vim.o.wildmenu = true

-- Ignore compiled files
vim.o.wildignore = "*.o,*~,*.pyc,*.qmlc,*jsc"

if fn.has("win32") == 1 then
    vim.o.wildignore = vim.o.wildignore .. ",.git*,.hg*,.svn*"
else
    vim.o.wildignore = vim.o.wildignore ..
                           ",*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store"
end

vim.o.wildignorecase = true

vim.o.cursorline = false

-- Always show current position
vim.o.ruler = true

-- Height of the command bar
vim.o.cmdheight = 1

-- A buffer becomes hidden when it is abandoned
vim.o.hidden = true

-- Configure backspace so it acts as it should act
vim.o.backspace = "eol,start,indent"
vim.o.whichwrap = vim.o.whichwrap .. ",<,>,h,l"

-- Ignore case when searching
vim.o.ignorecase = true

-- When searching try to be smart about cases
vim.o.smartcase = true

-- Highlight search results
vim.o.hlsearch = true

-- Makes search act like search in modern browsers
vim.o.incsearch = true

-- Don't redraw while executing macros (good performance config)
vim.o.lazyredraw = true

-- For regular expressions turn magic on
vim.o.magic = true

-- Show matching brackets when text indicator is over them
vim.o.showmatch = true

-- How many tenths of a second to blink when matching brackets
vim.o.matchtime = 3

-- No annoying sound on errors
vim.o.errorbells = false
vim.o.visualbell = false
vim.o.t_vb = ""
vim.o.tm = 300

-- TODO: Find a better way.
-- Disable scrollbars.
cmd [[set guioptions-=r]]
cmd [[set guioptions-=R]]
cmd [[set guioptions-=l]]
cmd [[set guioptions-=L]]

cmd [[
try
    set guifont=Fira\ Code:h12
catch
    set guifont=SauceCodePro\ Nerd\ Font\ Mono:h12
endtry
]]

-- }}}

-- Moving around, tabs, windows and buffers {{{

-- Disable highlight when <leader><cr> is pressed
map("n", "<leader><CR>", ":nohlsearch<CR>", {silent = true})

-- Jump to the previous git conflict start
map("n", "[cc", ":call search('^<\\{4,\\} \\w\\+.*$', 'Wb')<CR>",
    {silent = true, noremap = true})

-- Jump to the previous git conflict end
map("n", "[ce", ":call search('^>\\{4,\\} \\w\\+.*$', 'Wb')<CR>",
    {silent = true, noremap = true})

-- Jump to the next git conflict start
map("n", "]cc", ":call search('^<\\{4,\\} \\w\\+.*$', 'W')<CR>",
    {silent = true, noremap = true})

-- Jump to the next git conflict end
map("n", "]ce", ":call search('^>\\{4,\\} \\w\\+.*$', 'W')<CR>",
    {silent = true, noremap = true})

-- Jump to previous divider
map("n", "[cm", ":call search('^=\\{4,\\}$', 'Wb')<CR>",
    {silent = true, noremap = true})

-- Jump to next divider
map("n", "]cm", ":call search('^=\\{4,\\}$', 'W')<CR>",
    {silent = true, noremap = true})

-- }}}

-- Maps, Commands {{{

map("n", "]a", ':execute ":" . v:count . "next"<CR>',
    {silent = true, noremap = true})
map("n", "[a", ':execute ":" . v:count . "previous"<CR>',
    {silent = true, noremap = true})

map("n", "]l", ':execute ":" . v:count . "lnext"<CR>',
    {silent = true, noremap = true})
map("n", "[l", ':execute ":" . v:count . "lprevious"<CR>',
    {silent = true, noremap = true})

map("n", "]q", ':execute ":" . v:count . "cnext"<CR>',
    {silent = true, noremap = true})
map("n", "[q", ':execute ":" . v:count . "cprevious"<CR>',
    {silent = true, noremap = true})

map("n", "]b", ':execute ":" . v:count . "bnext"<CR>',
    {silent = true, noremap = true})
map("n", "[b", ':execute ":" . v:count . "bprevious"<CR>',
    {silent = true, noremap = true})

-- Switch to a terminal buffer using [count]gs.
map("n", "gs",
    '<cmd>execute "lua require\\"vimrc.terminal\\".switch_to_terminal(" . v:count . ")"<CR>',
    {silent = true, noremap = true})

-- Taking from here: https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
-- Allows running macros only on selected files.
map("x", "@",
    ':<C-u>echo "@".getcmdline() | execute ":\'<,\'>normal @" . nr2char(getchar())<CR>',
    {silent = true})

map("n", "L", "$", {silent = true})
map("v", "L", "$", {silent = true})

map("n", "H", "^", {silent = true})
map("v", "H", "^", {silent = true})

map("n", "Y", "y$", {silent = true})

-- Pressing <leader>ss will toggle and untoggle spell checking
map("n", "<leader>ss", ":setlocal spell!<CR>", {silent = true})

map("t", "<C-d>", "<PageDown>", {silent = true})
map("t", "<C-u>", "<PageUp>", {silent = true})

map("t", "<C-w><C-q>", "<C-\\><C-n>", {silent = true, noremap = true})
map("t", "<C-w><C-h>", "<C-\\><C-n><C-w>h", {silent = true, noremap = true})
map("t", "<C-w><C-j>", "<C-\\><C-n><C-w>j", {silent = true, noremap = true})
map("t", "<C-w><C-k>", "<C-\\><C-n><C-w>k", {silent = true, noremap = true})
map("t", "<C-w><C-l>", "<C-\\><C-n><C-w>l", {silent = true, noremap = true})

map("n", "gx", "<CMD>lua require'vimrc.buffers'.open_uri_under_cursor()<CR>",
    {silent = true, noremap = true})

cmd(
    "command! -range HighlightLine :lua require'vimrc.buffers'.highlight_line(0, <line1>, <line2>)")
cmd(
    "command! -bang -range ClearLineHighlights :lua require'vimrc.buffers'.clear_line_highlight(0, <line1>, <line2>, <q-bang> == '!')")
cmd(
    "command! -bang -range NextLineHighlight :lua require'vimrc.buffers'.jump_to_next_line_highlight()")

cmd [[ command! -bang -complete=customlist,fugitive#Complete -nargs=* -range FGit :lua require'vimrc.init'.run_git(<q-args>, <q-bang> ~= '!')]]

cmd [[command! -nargs=1 JiraStartTicket :let g:vimrc_active_jira_ticket=<f-args>]]
cmd [[command! JiraCloseTicket :if exists("g:vimrc_active_jira_ticket") | unlet g:vimrc_active_jira_ticket | endif]]
cmd [[command! -nargs=? JiraOpenTicket :call jira#open_ticket(<f-args>)]]
cmd [[command! -nargs=? JiraOpenTicketJson :call jira#open_ticket_in_json(<f-args>)]]

cmd [[command! Time :echohl IncSearch | echo "Time: " . strftime('%b %d %A, %H:%M') | echohl NONE]]

-- }}}

-- Abbreviations {{{

cmd [[abbreviate langauge language]]
cmd [[abbreviate Langauge Language]]

cmd [[cnoreabbrev git Git]]
cmd [[cnoreabbrev gst Gstatus]]
cmd [[cnoreabbrev fd Fd]]
cmd [[cnoreabbrev rg Rg]]

cmd [[cnoreabbrev frun FRun]]
cmd [[cnoreabbrev fh Fhdo]]

cmd [[cnoreabbrev time Time]]
cmd [[cnoreabbrev fgit FGit]]

cmd [[cnoreabbrev bc Bclose]]
cmd [[cnoreabbrev sh Shdo]]
cmd [[cnoreabbrev sh! Shdo!]]

-- }}}

-- Plugins {{{

g.markdown_fenced_languages = {
    "qml", "css", "html", "cpp", "json", "python", "javascript", "diff", "yaml",
    "sh", "ps1", "todo", "cmake", "qmake", "log", "vim", "sh", "gitconfig"
}

-- Pre-configuration {{{

-- Disable netrw in favor of vim-dirvish
g.loaded_netrwPlugin = 1

-- vim-polyglot {{{

-- Disable markdown support for polyglot because it messes up with syntax
-- highlighting.
g.polyglot_is_disabled = {
    markdown = true,
    json = true,
    vue = true,
    sensible = true
}

-- }}}

-- }}}

cmd [[command! InitPaq :lua require'vimrc.init'.init_paq()]]

-- TagBar {{{

g.tagbar_show_linenumbers = 1

-- }}}

-- nvim-lsp {{{

cmd [[augroup nvim_lsp_config]]
cmd [[autocmd!]]
cmd [[autocmd VimEnter * lua require'vimrc.lsp'.setup_lsp()]]
cmd [[augroup END]]

-- These are here so I remember to configure it when Neovim LSP supports it. {{{

g.vimrc_lsp_virtual_text_prefix_error = '✖'
g.vimrc_lsp_virtual_text_prefix_warning = '‼'
g.vimrc_lsp_virtual_text_prefix_information = 'ℹ'
g.vimrc_lsp_virtual_text_prefix_hint = '⦿'
g.vimrc_lsp_virtual_text_include_error_message = 0

-- }}}

fn.sign_define("LspDiagnosticsSignError", {
    text = "✖",
    texthl = "LspDiagnosticsDefaultError",
    linehl = "",
    numhl = ""
})
fn.sign_define("LspDiagnosticsSignWarning", {
    text = "‼",
    texthl = "LspDiagnosticsDefaultWarning",
    linehl = "",
    numhl = ""
})

fn.sign_define("LspDiagnosticsSignInformation", {
    text = "ℹ",
    texthl = "LspDiagnosticsDefaultInformation",
    linehl = "",
    numhl = ""
})
fn.sign_define("LspDiagnosticsSignHint", {
    text = "⦿",
    texthl = "LspDiagnosticsDefaultHint",
    linehl = "",
    numhl = ""
})

-- }}}

-- Completion {{{

cmd [[augroup vimrc_completion]]
cmd [[autocmd!]]
cmd [[autocmd BufReadPost,BufNewFile * lua require'vimrc.completion'.setup_completion(vim.api.nvim_get_current_buf())]]
cmd [[augroup END]]

-- }}}

-- Preview {{{

map("n", "sli", ":call quickfix#show_item_in_preview(v:true, line('.'))<CR>",
    {silent = true, noremap = true})
map("n", "sci", ":call quickfix#show_item_in_preview(v:false, line('.'))<CR>",
    {silent = true, noremap = true})

-- }}}

-- nvim-treesitter {{{

cmd [[augroup plugin_nvim_treesitter]]
cmd [[au!]]
cmd [[au FileType python,cpp,json,javascript,html,vue lua require'vimrc.init'.setup_treesitter()]]
cmd [[augroup END]]

-- }}}

-- firvish.nvim {{{

g.firvish_shell = "pwsh"

-- }}}

-- vim-markdown-folding {{{

g.markdown_fold_style = "nested"

-- }}}

-- nvim-dap {{{

map("n", "<leader>dc", ":lua require'dap'.continue()<CR>",
    {silent = true, noremap = true})
map("n", "<leader>dt", ":lua require'dap'.stop()<CR>",
    {silent = true, noremap = true})
map("n", "<leader>ds", ":lua require'dap'.step_into()<CR>",
    {silent = true, noremap = true})

map("n", "<leader>dh", ":lua require'dap.ui.variables'.hover()<CR>",
    {silent = true, noremap = true})
map("v", "<leader>dh", ":lua require'dap.ui.variables'.visual_hover()<CR>",
    {silent = true, noremap = true})
map("n", "<leader>do", ":lua require'dap'.step_out()<CR>",
    {silent = true, noremap = true})

map("n", "<leader>dn", ":lua require'dap'.step_over()<CR>",
    {silent = true, noremap = true})
map("n", "<leader>du", ":lua require'dap'.up()<CR>",
    {silent = true, noremap = true})
map("n", "<leader>dd", ":lua require'dap'.down()<CR>",
    {silent = true, noremap = true})

map("n", "<leader>db", ":lua require'dap'.toggle_breakpoint()<CR>",
    {silent = true, noremap = true})
map("n", "<leader>dB",
    ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
    {silent = true, noremap = true})
map("n", "<leader>dlp",
    ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
    {silent = true, noremap = true})

map("n", "<leader>dr", ":lua require'dap'.repl.toggle()<CR>",
    {silent = true, noremap = true})
map("n", "<leader>dl", ":lua require'dap'.list_breakpoints(true)<CR>",
    {silent = true, noremap = true})
map("n", "<leader>dp", ":lua require'dap.ui.variables'.scopes()<CR>",
    {silent = true, noremap = true})

cmd [[command! DapScopes :lua require'dap.ui.widgets'.sidebar(require'dap.ui.widgets'.scopes).open()]]
cmd [[command! DapFrames :lua require'dap.ui.widgets'.sidebar(require'dap.ui.widgets'.frames).open()]]

-- }}}

-- nvim-comment {{{

if vim.o.loadplugins == true then require'nvim_comment'.setup() end

-- }}}

-- }}}

-- Local Plugins {{{

-- Custom Options {{{

cmd [[command! -nargs=* -complete=customlist,options#complete Set :lua require'vimrc.options'.set(<q-args>, 0)]]
cmd [[command! -nargs=* -complete=customlist,options#complete_buf_local Setlocal :lua require'vimrc.options'.set(<q-args>, vim.fn.bufnr())]]

if fn.has("mac") == 1 then
    cmd [[set shell=zsh]]
    require"vimrc.options".set("shell=pwsh", 0)
else
    require"vimrc.options".set("shell=cmd", 0)
end

-- }}}

-- Git {{{

cmd [[command! -nargs=? StartReview :call git#start_review(<f-args>)]]
cmd [[command! ReviewDiff :call git#review_diff()]]
cmd [[command! FinishReview :call git#finish_review()]]

-- }}}

-- dotenv {{{

cmd [[command! -nargs=1 -complete=file SourceEnv :call dotenv#source(<f-args>)]]
cmd [[command! -nargs=1 -complete=file DeactivateEnv :call dotenv#deactivate(<f-args>)]]

-- }}}

-- Help {{{

map("n", "gh", ":call help#search_docs()<CR>", {silent = true})
cmd [[command! -nargs=1 Search :call help#search_docs(<f-args>)]]

-- }}}

-- Sort {{{

cmd [[command -complete=customlist,custom_sort#sort_command_completion -range -nargs=1 Sort :call custom_sort#sort(<f-args>, <line1>, <line2>)]]

-- }}}

-- QuickFix {{{

map("n", "<F10>", ":call quickfix#toggle()<CR>", {silent = true})
cmd [[command! ClearQuickFix :call setqflist([])]]

-- }}}

-- Text Objects {{{

-- URL text object.
map("x", "iu", ":<C-u>lua require'vimrc.textobjects'.url_text_object()<CR>",
    {silent = true, noremap = true})
map("o", "iu", ":<C-u>normal viu<CR>", {silent = true, noremap = true})

-- Line text objects.
map("x", "il", "g_o^", {silent = true, noremap = true})
map("o", "il", ":<C-u>normal vil<CR>", {silent = true, noremap = true})

-- Number
map("x", "in", ":<C-u>lua require'vimrc.textobjects'.number_text_object()<CR>",
    {silent = true, noremap = true})
map("o", "in", ":<C-u>normal viu<CR>", {silent = true, noremap = true})

-- }}}

-- Buffers {{{

require"vimrc.buffers".init()

map("v", "<leader>s", ":call buffers#visual_selection('search', '')<CR>",
    {silent = true, noremap = true})
map("v", "<leader>r", ":call buffers#visual_selection('replace', '')<CR>",
    {silent = true, noremap = true})

map("n", "<leader>cc",
    ":lua require'vimrc.buffers'.toggle_colorcolumn(vim.api.nvim_win_get_cursor(0)[2] + 1)<CR>",
    {silent = true, noremap = true})
map("n", "<leader>cd", ":lua require'vimrc.buffers'.toggle_colorcolumn(-1)<CR>",
    {silent = true, noremap = true})

cmd [[command! CleanTrailingWhiteSpace :lua require"vimrc.buffers".clean_trailing_spaces()]]

cmd [[command! Bclose :lua require"vimrc.buffers".close()]]
cmd [[command! -nargs=1 -bang Bdeletes :call buffers#wipe_matching('<args>', <q-bang>)]]
cmd [[command! Bdhidden :call buffers#delete_hidden()]]
cmd [[command! Bdnonexisting :call buffers#wipe_nonexisting_files()]]

cmd [[augroup plugin_buffers]]
cmd [[au!]]
cmd [[autocmd BufWritePre *.py,*.cpp,*.qml,*.js,*.txt,*.json,*.html :lua require"vimrc.buffers".clean_trailing_spaces()]]
cmd [[augroup END]]

cmd [[augroup trailing_white_space_highlight]]
cmd [[autocmd!]]
cmd [[autocmd BufReadPost * lua require"vimrc.buffers".setup_white_space_highlight(vim.fn.bufnr())]]
cmd [[augroup END]]

cmd [[augroup vimrc_buffer_events]]
cmd [[autocmd!]]
cmd [[autocmd User VimrcOptionSet lua local isize=require'vimrc.options'.get_option('indentsize', vim.fn.bufnr()); vim.cmd(string.format("setlocal tabstop=%s softtabstop=%s shiftwidth=%s", isize, isize, isize))]]
cmd [[augroup END]]

-- }}}

-- Terminal {{{

cmd [[command! -nargs=? -complete=shellcmd Terminal :call term#open(<f-args>)]]

cmd [[augroup term_plugin]]
cmd [[autocmd!]]
cmd [[autocmd TermOpen * startinsert]]
cmd [[autocmd TermOpen * lua require"vimrc.terminal".index_terminals()]]
cmd [[augroup END]]

-- }}}

-- Fold {{{

cmd [[augroup plugin_fold]]
cmd [[autocmd!]]
cmd [[autocmd BufReadPost,BufNew,BufEnter * if &foldtext != "fold#fold_text()" | setlocal foldtext=fold#fold_text() | endif]]
cmd [[augroup END]]

-- }}}

-- }}}

cmd [[augroup vimrc_init]]
cmd [[autocmd!]]
cmd [[autocmd BufReadPre,FileReadPre *.http :if !exists("g:nvim_http_preserve_responses") && &loadplugins | packadd nvim-http | endif]]
cmd [[autocmd TextYankPost * silent! lua vim.highlight.on_yank{on_visual=false, higroup="IncSearch", timeout=100}]]
cmd [[autocmd VimEnter * lua require'vimrc.init'.create_custom_nvim_server()]]
if vim.o.loadplugins == true then
    cmd [[autocmd VimEnter * colorscheme cosmic_latte ]]
end
-- Return to last edit position when opening files (You want this!)
cmd [[autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]]
cmd [[autocmd BufReadPost * lua require'vimrc.init'.load_dictionary()]]

cmd [[augroup END]]

if fn.filereadable(fn.expand("~/.vimrc")) == 1 then cmd "source ~/.vimrc" end

-- vim: foldmethod=marker
