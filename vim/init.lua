local vim = vim
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt
local add_command = vim.api.nvim_add_user_command

if vim.o.loadplugins == true then
    g.did_load_filetypes = 1
end

-- Disable some built-in plugins
g.loaded_2html_plugin = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_gzip = 1
g.loaded_logiPat = 1
g.loaded_netrw = 1
g.loaded_netrwFileHandlers = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_rrhelper = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_tutor_mode_plugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.qf_disable_statusline = 1

vim.opt.runtimepath:append(fn.expand("~/.dotfiles/vim"))
vim.opt.runtimepath:append(fn.expand("~/.dotfiles/vim/after"))
vim.opt.packpath:append(fn.expand("~/.dotfiles/vim/"))

local map = require("vimrc").map

-- General {{{

cmd([[filetype plugin on]])
cmd([[filetype indent on]])

opt.foldopen = "block,hor,jump,mark,percent,quickfix,search,tag"
opt.complete = ".,w,k,kspell,b"
opt.completeopt = "menuone,noselect"

opt.termguicolors = true
opt.foldenable = false
opt.colorcolumn = "81"

opt.showmode = false
opt.shortmess:append("c")
opt.splitbelow = true

opt.splitright = true
opt.signcolumn = "no"
opt.pumheight = 12

opt.exrc = true
opt.shiftround = true

-- Reduces the number of lines that are above the curser when I do zt.
opt.scrolloff = 3

-- Sets how many lines of history VIM has to remember
opt.history = 500

-- Show an arrow with a space for line breaks.
opt.showbreak = "↳ "
opt.breakindent = true
opt.breakindentopt = "shift:2"

opt.inccommand = "split"
opt.clipboard = "unnamed"

-- Set to auto read when a file is changed from the outside
opt.autoread = true

g.mapleader = " "
g.maplocalleader = " "

-- Use ripgrep over grep, if possible
if fn.executable("rg") then
    opt.grepprg = "rg --vimgrep $*"
    opt.grepformat = "%f:%l:%c:%m"
end

-- Means that you can undo even when you close a buffer/VIM
opt.undodir = fn.expand("~/.dotfiles/vim/temp_dirs/undodir")
opt.undofile = true

-- Turn backup off, since most stuff is in SVN, git et.c anyway...
opt.swapfile = false

-- Use spaces instead of tabs
opt.expandtab = true

-- Be smart when using tabs ;)
opt.smarttab = true

-- 1 tab == 4 spaces
opt.shiftwidth = 4
opt.tabstop = 4

opt.linebreak = true
opt.textwidth = 500

opt.autoindent = true
opt.smartindent = true

opt.foldtext = "fold#fold_text()"

if fn.executable("pwsh") == 1 and fn.exists("$VIMRC_PWSH_ENABLED") == 1 then
    opt.shell = "pwsh"
    opt.shellquote = ""
    opt.shellpipe = "| Out-File -Encoding UTF8"
    opt.shellxquote = ""
    opt.shellcmdflag = "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command"
    opt.shellredir = "| Out-File -Encoding UTF8 %s | Out-Null"
elseif fn.has("mac") == 1 then
    vim.opt.shell = "zsh"
else
    vim.opt.shell = "cmd"
end

-- Specify the behavior when switching between buffers
-- Use the current tab for openning files from quickfix.
-- Otherwise it gets really annoying and each file is opened
-- in a different tab.
opt.switchbuf = "useopen,usetab"
opt.stal = 2

if fn.expand("$MANPAGER") ~= "$MANPAGER" then
    cmd("let $MANPAGER=''")
end

-- }}}

-- User Interface {{{

-- Always show the status line
opt.laststatus = 2

opt.pumblend = 10

opt.tabline = '%!luaeval("' .. "require'vimrc.tabline'.init()" .. '")'
opt.title = true
opt.titlelen = 80
opt.titlestring = table.concat({
    "%<",
    '%{exists("$VIRTUAL_ENV") ? ".venv" : ""}',
    '%{exists("$VIRTUAL_ENV") && exists("$ENV_NAME") ? "://" : ""}',
    '%{exists("$ENV_NAME") ? expand("$ENV_NAME") : ""}',
    "%=",
    '%{strftime("%b\\ %d\\ %A,\\ %H:%M")}',
})
opt.statusline = '%!luaeval("require\'vimrc.statusline\'.init(" . g:statusline_winid . ")")'

if vim.env.VIMRC_BACKGROUND == "dark" then
    vim.opt.background = "dark"
else
    vim.opt.background = "light"
end

opt.diffopt = "vertical,filler,context:5,closeoff,algorithm:histogram,internal"

opt.langmenu = "en"
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.relativenumber = true

-- Turn on the Wild menu
opt.wildmenu = true
cmd([[set wildchar=<C-n>]])

-- Ignore compiled files
opt.wildignore:append("*.o")
opt.wildignore:append("*~")
opt.wildignore:append("*.pyc")
opt.wildignore:append("*.qmlc")
opt.wildignore:append("*jsc")

if fn.has("mac") == 1 then
    opt.wildignore:append("*/.DS_Store")
end

opt.wildignorecase = true

opt.cursorline = false

-- Always show current position
opt.ruler = true

-- Height of the command bar
opt.cmdheight = 1

-- A buffer becomes hidden when it is abandoned
opt.hidden = true

-- Configure backspace so it acts as it should act
opt.backspace = "eol,start,indent"
opt.whichwrap:append(",<,>,h,l")

-- Ignore case when searching
opt.ignorecase = true

-- When searching try to be smart about cases
opt.smartcase = true

-- Highlight search results
opt.hlsearch = true

-- Makes search act like search in modern browsers
opt.incsearch = true

-- Don't redraw while executing macros (good performance config)
opt.lazyredraw = true

-- For regular expressions turn magic on
opt.magic = true

-- Show matching brackets when text indicator is over them
opt.showmatch = true

-- How many tenths of a second to blink when matching brackets
opt.matchtime = 3

-- No annoying sound on errors
opt.errorbells = false
opt.visualbell = false
opt.tm = 300

cmd([[
try
    set guifont=Fira\ Code:h12
catch
    set guifont=SauceCodePro\ Nerd\ Font\ Mono:h12
endtry
]])

-- }}}

-- Moving around, tabs, windows and buffers {{{

map("n", "<Up>", "<NOP>", { noremap = true })
map("n", "<Left>", "<NOP>", { noremap = true })
map("n", "<Right>", "<NOP>", { noremap = true })
map("n", "<Down>", "<NOP>", { noremap = true })

map("c", "<C-u>", "<Up>", { noremap = true })
map("c", "<C-d>", "<Down>", { noremap = true })

-- Disable highlight when <leader><cr> is pressed
map("n", "<leader><CR>", ":nohlsearch<CR>", { silent = true })

-- Jump to the previous git conflict start
map("n", "[cc", ":call search('^<\\{4,\\} \\w\\+.*$', 'Wb')<CR>", {
    silent = true,
    noremap = true,
})

-- Jump to the previous git conflict end
map("n", "[ce", ":call search('^>\\{4,\\} \\w\\+.*$', 'Wb')<CR>", {
    silent = true,
    noremap = true,
})

-- Jump to the next git conflict start
map("n", "]cc", ":call search('^<\\{4,\\} \\w\\+.*$', 'W')<CR>", { silent = true, noremap = true })

-- Jump to the next git conflict end
map("n", "]ce", ":call search('^>\\{4,\\} \\w\\+.*$', 'W')<CR>", { silent = true, noremap = true })

-- Jump to previous divider
map("n", "[cm", ":call search('^=\\{4,\\}$', 'Wb')<CR>", { silent = true, noremap = true })

-- Jump to next divider
map("n", "]cm", ":call search('^=\\{4,\\}$', 'W')<CR>", { silent = true, noremap = true })

-- }}}

-- Maps, Commands {{{

map("n", "]a", ':execute ":" . v:count . "next"<CR>', { silent = true, noremap = true })
map("n", "[a", ':execute ":" . v:count . "previous"<CR>', { silent = true, noremap = true })

map("n", "]l", ':execute ":" . v:count . "lnext"<CR>', { silent = true, noremap = true })
map("n", "[l", ':execute ":" . v:count . "lprevious"<CR>', { silent = true, noremap = true })

map("n", "]q", ':execute ":" . v:count . "cnext"<CR>', { silent = true, noremap = true })
map("n", "[q", ':execute ":" . v:count . "cprevious"<CR>', { silent = true, noremap = true })

map("n", "]b", ':execute ":" . v:count . "bnext"<CR>', { silent = true, noremap = true })
map("n", "[b", ':execute ":" . v:count . "bprevious"<CR>', { silent = true, noremap = true })

-- Switch to a terminal buffer using [count]gs.
map(
    "n",
    "<leader>gt",
    '<cmd>execute "lua require\\"vimrc.terminal\\".switch_to_terminal(" . v:count . ")"<CR>',
    { silent = true, noremap = true }
)

-- Taking from here: https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
-- Allows running macros only on selected files.
map(
    "x",
    "@",
    ':<C-u>echo "@".getcmdline() | execute ":\'<,\'>normal @" . nr2char(getchar())<CR>',
    { silent = true, noremap = true }
)

map("x", ".", ":normal .<CR>", { silent = true })

map("n", "L", "$", { silent = true })
map("v", "L", "$", { silent = true })

map("n", "H", "^", { silent = true })
map("v", "H", "^", { silent = true })

map("n", "Y", "y$", { silent = true })

-- Pressing <leader>ss will toggle and untoggle spell checking
map("n", "<leader>ss", ":setlocal spell!<CR>", { silent = true })

map("t", "<C-d>", "<PageDown>", { silent = true })
map("t", "<C-u>", "<PageUp>", { silent = true })

map("t", "<C-w><C-q>", "<C-\\><C-n>", { silent = true, noremap = true })
map("t", "<C-w><C-h>", "<C-\\><C-n><C-w>h", { silent = true, noremap = true })
map("t", "<C-w><C-j>", "<C-\\><C-n><C-w>j", { silent = true, noremap = true })
map("t", "<C-w><C-k>", "<C-\\><C-n><C-w>k", { silent = true, noremap = true })
map("t", "<C-w><C-l>", "<C-\\><C-n><C-w>l", { silent = true, noremap = true })

-- }}}

-- Abbreviations {{{

cmd([[abbreviate langauge language]])
cmd([[abbreviate Langauge Language]])
cmd([[abbreviate lenght length]])
cmd([[abbreviate Lenght Length]])

cmd([[cnoreabbrev git Git]])
cmd([[cnoreabbrev gst Gstatus]])
cmd([[cnoreabbrev fd Fd]])
cmd([[cnoreabbrev rg Rg]])

cmd([[cnoreabbrev frun FRun]])
cmd([[cnoreabbrev fh Fhdo]])

cmd([[cnoreabbrev time Time]])
cmd([[cnoreabbrev fgit FGit]])

cmd([[cnoreabbrev bc Bclose]])

-- }}}

-- Plugins {{{

-- Pre-configuration {{{

if vim.o.loadplugins == true then
    cmd([[augroup vimrc_source_post]])
    cmd([[au!]])
    cmd([[autocmd SourcePost * lua require"vimrc".on_source_post()]])
    cmd([[augroup END]])
end

-- }}}

-- vim-polyglot {{{

-- Disable markdown support for polyglot because it messes up with syntax
-- highlighting.
if fn.exists("$VIMRC_TREESITTER_DISABLED") ~= 1 then
    g.vimrc_treesitter_filetypes = {
        "astro",
        "bash",
        "beancount",
        "bibtex",
        "c",
        "c_sharp",
        "clojure",
        "cmake",
        "comment",
        "commonlisp",
        "cooklang",
        "cpp",
        "css",
        "cuda",
        "d",
        "dart",
        "devicetree",
        "dockerfile",
        "dot",
        "eex",
        "elixir",
        "elm",
        "elvish",
        "erlang",
        "fennel",
        "fish",
        "foam",
        "fortran",
        "fusion",
        "gdscript",
        "gleam",
        "glimmer",
        "glsl",
        "go",
        "godot_resource",
        "gomod",
        "gowork",
        "graphql",
        "hack",
        "haskell",
        "hcl",
        "heex",
        "help",
        "hjson",
        "hocon",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "julia",
        "kotlin",
        "lalrpop",
        "latex",
        "ledger",
        "llvm",
        "lua",
        "make",
        "markdown",
        "ninja",
        "nix",
        "norg",
        "ocaml",
        "ocaml_interface",
        "ocamllex",
        "pascal",
        "perl",
        "php",
        "phpdoc",
        "pioasm",
        "prisma",
        "pug",
        "python",
        "ql",
        "query",
        "r",
        "rasi",
        "regex",
        "rego",
        "rst",
        "ruby",
        "rust",
        "scala",
        "scheme",
        "scss",
        "slint",
        "solidity",
        "sparql",
        "supercollider",
        "surface",
        "svelte",
        "swift",
        "teal",
        "tlaplus",
        "todotxt",
        "toml",
        "tsx",
        "turtle",
        "typescript",
        "vala",
        "verilog",
        "vim",
        "vue",
        "wgsl",
        "yaml",
        "yang",
        "zig",
    }
end

-- }}}

-- TagBar {{{

g.tagbar_show_linenumbers = 1

-- }}}

-- nvim-lsp {{{

if vim.o.loadplugins == true then
    cmd([[augroup vimrc_nvim_lsp_config]])
    cmd([[autocmd!]])
    cmd([[autocmd VimEnter * lua require'vimrc.lsp'.setup_lsp()]])
    cmd([[augroup END]])
end

-- }}}

-- Completion {{{

if vim.o.loadplugins == true then
    require("sekme").setup({
        completion_key = "<C-n>",
        completion_rkey = "<C-p>",
        custom_sources = {
            {
                complete = require("vimrc.completions.mnemonics").complete,
            },
            {

                complete = function(_, base)
                    local rt = require("zettelkasten").completefunc(0, base)
                    if rt == 0 then
                        return {}
                    end

                    return rt
                end,
                filetypes = { "markdown" },
            },
        },
    })
end

-- }}}

-- nvim-treesitter {{{

if vim.o.loadplugins == true and g.vimrc_treesitter_filetypes ~= nil then
    cmd([[augroup vimrc_plugin_nvim_treesitter]])
    cmd([[au!]])
    cmd(
        "au FileType "
            .. table.concat(g.vimrc_treesitter_filetypes, ",")
            .. " setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()"
    )
    cmd([[augroup END]])

    cmd([[augroup vimrc_plugin_nvim_treesitter_init]])
    cmd([[au!]])
    cmd(
        "au FileType "
            .. table.concat(g.vimrc_treesitter_filetypes, ",")
            .. " lua require'vimrc'.setup_treesitter()"
    )
    cmd([[augroup END]])
end

-- }}}

-- firvish.nvim {{{

g.firvish_shell = "pwsh"
g.firvish_use_default_mappings = true

if fn.has("mac") == 1 and vim.o.loadplugins then
    require("firvish.notifications").notify = function(msg, _, opts)
        opts.title = opts.title or "Neovim"
        local firvish = require("firvish.job_control")
        firvish.start_job({
            cmd = {
                "pwsh",
                "-C",
                "Post-Notification",
                "-Title",
                '"' .. opts.title .. '"',
                "-Message",
                '"' .. msg .. '"',
            },
            filetype = "firvish-job",
            title = "Notification",
            is_background_job = true,
            listed = false,
        })
    end
end

-- }}}

-- comment.nvim {{{

if vim.o.loadplugins == true then
    require("Comment").setup({ ignore = "^$" })

    local ft = require("Comment.ft")
    ft.qml = { "//%s", "/*%s*/" }
end

-- }}}

-- options.nvim {{{

if vim.o.loadplugins == true then
    local options = require("options")

    options.register_option({
        name = "tags_completion_enabled",
        default = true,
        type_info = "boolean",
        source = "lsp",
        buffer_local = true,
    })
    options.register_option({
        name = "clstrailingwhitespace",
        default = true,
        type_info = "boolean",
        source = "buffers",
        buffer_local = true,
    })
    options.register_option({
        name = "lsp_tagfunc_enabled",
        default = true,
        type_info = "boolean",
        source = "vimrc",
        global = true,
    })
    options.register_option({
        name = "clstrailingspacelimit",
        default = 0,
        type_info = "number",
        source = "buffers",
        buffer_local = true,
        description = "If the number of trailing white spaces below this number, they will be cleared automatically. Otherwise you will be prompted for each one.",
    })
    options.register_option({
        name = "trailingwhitespacehighlight",
        default = true,
        type_info = "boolean",
        source = "buffers",
        buffer_local = true,
    })
    options.register_option({
        name = "indentsize",
        default = 4,
        type_info = "number",
        source = "buffers",
        buffer_local = true,
    })
    options.register_option({
        name = "shell",
        default = "pwsh",
        type_info = "string",
        source = "options",
        global = true,
    })
    options.register_option({
        name = "scratchpad",
        default = false,
        type_info = "boolean",
        source = "options",
        buffer_local = true,
    })
    options.register_option({
        name = "markdownfenced",
        default = {},
        type_info = "table",
        source = "buffers",
        buffer_local = true,
    })
    options.register_option({
        name = "todofenced",
        default = {},
        type_info = "table",
        source = "todo",
        buffer_local = true,
    })
    options.register_option({
        name = "minimal_buffer",
        default = false,
        type_info = "boolean",
        source = "buffers",
        buffer_local = true,
    })

    cmd([[augroup vimrc_options_plugin]])
    cmd(
        [[autocmd BufReadPost *.md,todo.txt :lua require"options".set_modeline(vim.api.nvim_get_current_buf())]]
    )
    cmd([[augroup END]])
end

-- }}}

-- cosmic_latte {{{

if vim.o.loadplugins == true then
    cmd([[autocmd VimEnter * colorscheme cosmic_latte ]])
end

-- }}}

-- }}}

-- Local Plugins {{{

-- Buffers, Jira, Time {{{

map(
    "n",
    "gx",
    "<CMD>lua require'vimrc.buffers'.open_uri_under_cursor()<CR>",
    { silent = true, noremap = true }
)

add_command(
    "FGit",
    ":lua require'vimrc'.run_git(<q-args>, <q-bang> ~= '!')",
    { complete = "customlist,fugitive#Complete", nargs = "*", range = true }
)

add_command("JiraStartTicket", "let g:vimrc_active_jira_ticket=<f-args>", { nargs = 1 })
add_command("JiraCloseTicket", function(_)
    if g.vimrc_active_jira_ticket ~= nil then
        g.vimrc_active_jira_ticket = nil
    end
end, {
    nargs = 1,
})

add_command("JiraOpenTicket", ":call jira#open_ticket(<f-args>)", { nargs = "?" })
add_command("JiraOpenTicketJson", ":call jira#open_ticket_in_json(<f-args>)", { nargs = "?" })

add_command("Time", function(_)
    cmd([[echohl IncSearch | echo "Time: " . strftime('%b %d %A, %H:%M') | echohl NONE']])
end, {})

-- }}}

-- todo {{{

if vim.o.loadplugins == true then
    cmd([[augroup vimrc_plugin_todo_init]])
    cmd([[au!]])
    cmd([[autocmd FileType todo :lua require"vimrc.todo".init()]])
    cmd([[augroup END]])
end

-- }}}

-- dotenv {{{

if vim.o.loadplugins == true then
    cmd([[command! -nargs=1 -complete=file SourceEnv :call dotenv#source(<f-args>)]])
    cmd([[command! -nargs=1 -complete=file DeactivateEnv :call dotenv#deactivate(<f-args>)]])
end

-- }}}

-- Help {{{

if vim.o.loadplugins == true then
    map("n", "gh", ":call help#search_docs()<CR>", { silent = true })
    cmd([[command! -nargs=1 Search :call help#search_docs(<f-args>)]])
end

-- }}}

-- Sort {{{

cmd(
    [[command -complete=customlist,custom_sort#sort_command_completion -range -nargs=1 -bar Sort :call custom_sort#sort(<f-args>, <line1>, <line2>)]]
)

-- }}}

-- QuickFix {{{

map("n", "<C-q>z", ":cclose<CR>", { silent = true })
map(
    "n",
    "<C-q>o",
    ":botright copen | if exists('g:vimrc_quickfix_size_cache') && has_key(g:vimrc_quickfix_size_cache, tabpagenr()) | execute 'resize ' . g:vimrc_quickfix_size_cache[tabpagenr()] | endif<CR>",
    { silent = true }
)
map(
    "n",
    "<C-q>lo",
    ":botright lopen | if exists('g:vimrc_quickfix_size_cache') && has_key(g:vimrc_quickfix_size_cache, tabpagenr()) | execute 'resize ' . g:vimrc_quickfix_size_cache[tabpagenr()] | endif<CR>",
    { silent = true }
)
map("n", "<C-q>lz", ":lclose<CR>", { silent = true })

-- }}}

-- Text Objects {{{

if vim.o.loadplugins == true then
    require("vimrc.textobjects").init()
end

-- }}}

-- Buffers {{{

if vim.o.loadplugins == true then
    require("vimrc.buffers").init()
end

map(
    "v",
    "<leader>s",
    ":call buffers#visual_selection('search', '')<CR>",
    { silent = true, noremap = true }
)
map(
    "v",
    "<leader>r",
    ":call buffers#visual_selection('replace', '')<CR>",
    { silent = true, noremap = true }
)

map(
    "n",
    "<leader>cc",
    ":lua require'vimrc.buffers'.toggle_colorcolumn(vim.api.nvim_win_get_cursor(0)[2] + 1)<CR>",
    { silent = true, noremap = true }
)
map(
    "n",
    "<leader>cd",
    ":lua require'vimrc.buffers'.toggle_colorcolumn(-1)<CR>",
    { silent = true, noremap = true }
)

cmd([[command! CleanTrailingWhiteSpace :lua require"vimrc.buffers".clean_trailing_spaces()]])

cmd([[command! Bclose :lua require"vimrc.buffers".close()]])
cmd([[command! -nargs=1 -bang Bdeletes :call buffers#wipe_matching('<args>', <q-bang>)]])
cmd([[command! Bdnonexisting :call buffers#wipe_nonexisting_files()]])

cmd([[augroup vimrc_plugin_buffers]])
cmd([[au!]])
cmd(
    [[autocmd BufWritePre *.py,*.cpp,*.qml,*.js,*.txt,*.json,*.html,*.lua :lua require"vimrc.buffers".clean_trailing_spaces()]]
)
cmd([[augroup END]])

cmd([[augroup vimrc_trailing_white_space_highlight]])
cmd([[autocmd!]])
cmd(
    [[autocmd BufReadPost * lua require"vimrc.buffers".setup_white_space_highlight(vim.fn.bufnr())]]
)
cmd([[augroup END]])

-- }}}

-- Terminal {{{

cmd([[command! -nargs=? -complete=shellcmd Terminal :call term#open(<f-args>)]])

cmd([[augroup vimrc_term_plugin]])
cmd([[autocmd!]])
cmd([[autocmd TermOpen * lua require"vimrc.terminal".index_terminals()]])
cmd([[augroup END]])

-- }}}

-- Fold {{{

cmd([[augroup vimrc_plugin_fold]])
cmd([[autocmd!]])
cmd(
    [[autocmd BufReadPost,BufNew,BufEnter * if &foldtext != "fold#fold_text()" | setlocal foldtext=fold#fold_text() | endif]]
)
cmd([[augroup END]])

-- }}}

-- Custom Find {{{

if fn.executable("fd") then
    cmd(
        [[ command! -complete=customlist,find#complete -nargs=* -range Find :lua require'vimrc.find'.open_files(<q-args>, false)]]
    )
    cmd(
        [[ command! -complete=customlist,find#complete -nargs=* -range SFind :lua require'vimrc.find'.open_files(<q-args>, true)]]
    )
end

-- }}}

-- }}}

if vim.o.loadplugins == true then
    cmd([[augroup vimrc_init]])
    cmd([[autocmd!]])
    cmd(
        [[autocmd BufReadPre,FileReadPre *.http :if !exists("g:vimrc_rest_nvim_loaded") && &loadplugins | packadd rest.nvim | call luaeval('require"vimrc".setup_rest_nvim()') | let g:vimrc_rest_nvim_loaded = v:true | endif]]
    )
end

cmd(
    [[autocmd TextYankPost * silent! lua vim.highlight.on_yank{on_visual=false, higroup="IncSearch", timeout=100}]]
)

cmd([[autocmd VimEnter * lua require'vimrc'.create_custom_nvim_server()]])

if vim.o.loadplugins == true then
    cmd(
        [[autocmd VimEnter * runtime! ftdetect/*.vim ftdetect/*.lua after/ftdetect/*.vim after/ftdetect/*.lua]]
    )
end

-- Return to last edit position when opening files (You want this!)
cmd(
    [[autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]]
)
cmd([[autocmd BufReadPost * lua require'vimrc'.load_dictionary()]])

cmd([[augroup END]])

if fn.filereadable(fn.expand("~/.vimrc")) == 1 then
    cmd("source ~/.vimrc")
end

-- vim: foldmethod=marker
