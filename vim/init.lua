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

cmd [[
set runtimepath^=~/.dotfiles/vim,~/.dotfiles/vim/after
]]

-- cmd [[filetype plugin on]]
-- cmd [[filetype indent on]]

vim.o.foldopen = "block,hor,jump,mark,percent,quickfix,search,tag"
vim.o.complete = ".,w,k,kspell,b"
vim.o.completeopt = "menuone,noinsert,noselect"

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
vim.o.undodir = "~/.dotfiles/vim/temp_dirs/undodir"
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

-- TODO: Find a better way.
cmd [[set foldtext=fold#fold_text()]]

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

-- TODO: Find a better way.
cmd [[set tabline=%!tabline#config()]]

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

-- Disable scrollbars (real hackers don't use scrollbars for navigation!)

-- TODO: Find a better way.
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
map("n", "]cc", ":call search('^>\\{4,\\} \\w\\+.*$', 'W')<CR>",
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

cmd [[command! -nargs=1 JiraStartTicket :let g:vimrc_active_jira_ticket=<f-args>]]
cmd [[command! JiraCloseTicket :if exists("g:vimrc_active_jira_ticket") | unlet g:vimrc_active_jira_ticket | endif]]
cmd [[command! -nargs=? JiraOpenTicket :call jira#open_ticket(<f-args>)]]
cmd [[command! -nargs=? JiraOpenTicketJson :call jira#open_ticket_in_json(<f-args>)]]

cmd [[command Time :echohl IncSearch | echo "Time: " . strftime('%b %d %A, %H:%M') | echohl NONE]]

-- command! PackUpdate call PackInit() | call minpac#update('', {'do': 'call minpac#status()'})
-- command! PackClean  call PackInit() | call minpac#clean()
-- command! PackStatus call PackInit() | call minpac#status()

-- }}}

-- Abbreviations {{{

cmd [[abbreviate langauge language]]
cmd [[abbreviate Langauge Language]]

-- }}}

-- Plugins {{{

-- Pre-configuration {{{

-- Disable netrw in favor of vim-dirvish
g.loaded_netrwPlugin = 1

-- Disable markdown support for polyglot because it messes up with syntax
-- highlighting.
g.polyglot_is_disabled = {
    markdown = true,
    json = true,
    vue = true,
    sensible = true
}

-- }}}

cmd [[command! InitPaq :lua require'vimrc.init_utils'.init_paq()]]

-- TagBar {{{

g.tagbar_show_linenumbers = 1

-- }}}

-- nvim-lsp {{{

require'vimrc.lsp'.setup_lsp()

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

cmd [[source ~/.dotfiles/vim/completion.vim]]

cmd [[augroup vimrc_completion]]
cmd [[autocmd BufReadPost * lua require'vimrc.completion'.setup_completion(vim.api.nvim_get_current_buf())]]
cmd [[augroup END]]

-- }}}

-- Preview {{{

map("n", "sli", ":call quickfix#show_item_in_preview(v:true, line('.'))<CR>",
    {silent = true, noremap = true})
map("n", "sci", ":call quickfix#show_item_in_preview(v:false, line('.'))<CR>",
    {silent = true, noremap = true})

-- }}}

-- nvim-gdb {{{

g.nvimgdb_config_override = {
    key_step = "<leader>s",
    key_frameup = "<leader>u",
    key_framedown = "<leader>d",
    key_continue = "<leader>c",
    key_next = "<leader>n"
}

-- }}}

-- nvim-treesitter {{{

cmd [[augroup plugin_nvim_treesitter]]
cmd [[au!]]
cmd [[au FileType python,cpp,json,javascript,html,vue lua require'vimrc.init_utils'.setup_treesitter()]]
cmd [[augroup END]]

-- }}}

-- firvish.nvim {{{

g.firvish_shell = "pwsh"

-- }}}

-- }}}

cmd [[augroup vimrc_init]]
cmd [[autocmd!]]
cmd [[autocmd BufReadPre,FileReadPre *.http :if !exists("g:nvim_http_preserve_responses") | packadd nvim-http | endif]]
cmd [[autocmd TextYankPost * silent! lua vim.highlight.on_yank{on_visual=false, higroup="IncSearch", timeout=100}]]
cmd [[autocmd VimEnter * lua require'vimrc.init_utils'.create_custom_nvim_server()]]
cmd [[autocmd VimEnter * colorscheme cosmic_latte]]

-- Return to last edit position when opening files (You want this!)
cmd [[autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]]
cmd [[autocmd BufReadPost * lua require'vimrc.init_utils'.load_dictionary()]]

cmd [[augroup END]]

if fn.filereadable("~/.vimrc") then cmd "source ~/.vimrc" end

-- vim: foldmethod=marker
