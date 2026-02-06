local vim = vim
local keymap = vim.keymap
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt
local api = vim.api

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
g.loaded_matchit = 1
g.qf_disable_statusline = 1

opt.runtimepath:append(fn.expand("~/.dotfiles/vim"))
opt.runtimepath:append(fn.expand("~/.dotfiles/vim/after"))
opt.packpath:append(fn.expand("~/.dotfiles/vim/"))

-- General {{{

cmd([[filetype plugin on]])
cmd([[filetype indent on]])

opt.foldopen = "block,hor,jump,mark,percent,quickfix,search,tag"
opt.complete = ".,w,k,kspell,b"
opt.completeopt = "menuone,noselect"
opt.wildoptions = "pum,tagfile"

opt.termguicolors = true
opt.foldenable = false

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

-- Prefer ugrep for now.
if false and fn.executable("rg") then
    opt.grepprg = "rg --vimgrep $*"
    opt.grepformat = "%f:%l:%c:%m"
end

if fn.executable("ugrep") then
    opt.grepprg = "ugrep -RInk -j -u --tabs=1 --ignore-files"
    opt.grepformat = "%f:%l:%c:%m,%f+%l+%c+%m,%-G%f|%l|%c|%m"
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
    opt.shellcmdflag =
        "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command $PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText;"
    opt.shellredir = "| Out-File -Encoding UTF8 %s | Out-Null"
elseif fn.has("mac") == 1 then
    opt.shell = "zsh"
elseif fn.has("unix") == 1 then
    opt.shell = "bash"
else
    opt.shell = "cmd"
end

-- Specify the behavior when switching between buffers
-- Use the current tab for openning files from quickfix.
-- Otherwise it gets really annoying and each file is opened
-- in a different tab.
-- Without `uselast`, nvim-dap doesn't open the buffer to the breakpoint.
opt.switchbuf = "useopen,usetab,uselast"
opt.stal = 2

if fn.expand("$MANPAGER") ~= "$MANPAGER" then
    cmd([[let $MANPAGER='']])
end

-- }}}

-- User Interface {{{

-- Always show the status line
opt.laststatus = 2

if vim.g.neovide then
    opt.winblend = 18
else
    opt.winblend = 8
end

opt.pumblend = 10

opt.tabline = '%!luaeval("' .. "require'vimrc.tabline'.init()" .. '")'
opt.title = true
opt.titlelen = 80
opt.titlestring = table.concat {
    "%<",
    '%{exists("$VIRTUAL_ENV") ? ".venv" : ""}',
    '%{exists("$VIRTUAL_ENV") && exists("$ENV_NAME") ? "://" : ""}',
    '%{exists("$ENV_NAME") ? expand("$ENV_NAME") : ""}',
    "%=",
    '%{strftime("%b\\ %d\\ %A,\\ %H:%M")}',
}
opt.statusline = '%!luaeval("require\'vimrc.statusline\'.init(" . g:statusline_winid . ")")'

if vim.env.VIMRC_BACKGROUND == "dark" then
    opt.background = "dark"
else
    opt.background = "light"
end

opt.diffopt = "vertical,filler,context:7,closeoff,algorithm:histogram,internal,linematch:60"

opt.langmenu = "en"
opt.number = true
opt.numberwidth = 2
opt.relativenumber = true

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
opt.cursorline = true
opt.cursorlineopt = "number"

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
opt.timeoutlen = 300
if fn.has("mac") == 1 then
    opt.guifont = "JetBrainsMono Nerd Font Mono:h13"
else
    opt.guifont = "JetBrainsMono Nerd Font Mono:h9"
end
opt.mouse = ""

if fn.executable("just") then
    opt.makeprg = "just $*"
    cmd([[cabbrev just Just]])

    if vim.o.loadplugins == true then
        api.nvim_create_user_command("Just", ":Cfrun just <args>", {
            nargs = "*",
            complete = function(_, _, _)
                local output = fn.systemlist("just --summary")[1]
                local recipes = string.split(output, " ")
                return recipes
            end,
            bar = true,
        })

        api.nvim_create_user_command("Make", ":Cfrun just <args>", { nargs = "*", bar = true })
        api.nvim_create_user_command("Lmake", ":Lfrun just <args>", { nargs = "*", bar = true })
    end
end

-- Neovide {{{

if vim.g.neovide then
    g.neovide_cursor_vfx_mode = "railgun"
    g.neovide_cursor_animate_in_insert_mode = false
    g.neovide_cursor_trail_size = 0.5
    g.neovide_hide_mouse_when_typing = true
    g.neovide_scroll_animation_length = 0.0
    g.neovide_cursor_animation_length = 0.01
    g.neovide_window_blurred = true

    keymap.set("n", "<F11>", function()
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
    end, { remap = false })
end

-- }}}

-- }}}

-- Moving around, tabs, windows and buffers {{{

keymap.set("n", "<Up>", "<NOP>", { remap = false })
keymap.set("n", "<Left>", "<NOP>", { remap = false })
keymap.set("n", "<Right>", "<NOP>", { remap = false })
keymap.set("n", "<Down>", "<NOP>", { remap = false })

keymap.set("c", "<C-u>", "<Up>", { remap = false })
keymap.set("c", "<C-d>", "<Down>", { remap = false })

-- Disable highlight when <leader><cr> is pressed
keymap.set("n", "<leader><CR>", ":nohlsearch<CR>", { silent = true })

-- Jump to the previous git conflict start
keymap.set("n", "[cc", ":call search('^<\\{4,\\} \\w\\+.*$', 'Wb')<CR>", {
    silent = true,
    remap = false,
})

-- Jump to the previous git conflict end
keymap.set("n", "[ce", ":call search('^>\\{4,\\} \\w\\+.*$', 'Wb')<CR>", {
    silent = true,
    remap = false,
})

-- Jump to the next git conflict start
keymap.set(
    "n",
    "]cc",
    ":call search('^<\\{4,\\} \\w\\+.*$', 'W')<CR>",
    { silent = true, remap = false }
)

-- Jump to the next git conflict end
keymap.set(
    "n",
    "]ce",
    ":call search('^>\\{4,\\} \\w\\+.*$', 'W')<CR>",
    { silent = true, remap = false }
)

-- Jump to previous divider
keymap.set("n", "[cm", ":call search('^=\\{4,\\}$', 'Wb')<CR>", { silent = true, remap = false })

-- Jump to next divider
keymap.set("n", "]cm", ":call search('^=\\{4,\\}$', 'W')<CR>", { silent = true, remap = false })

-- }}}

-- Maps, Commands {{{

keymap.set("n", "]a", ':execute ":" . v:count . "next"<CR>', { silent = true, remap = false })
keymap.set("n", "[a", ':execute ":" . v:count . "previous"<CR>', { silent = true, remap = false })

keymap.set("n", "]l", ':execute ":" . v:count . "lnext"<CR>', { silent = true, remap = false })
keymap.set("n", "[l", ':execute ":" . v:count . "lprevious"<CR>', { silent = true, remap = false })

keymap.set("n", "]q", ':execute ":" . v:count . "cnext"<CR>', { silent = true, remap = false })
keymap.set("n", "[q", ':execute ":" . v:count . "cprevious"<CR>', { silent = true, remap = false })

keymap.set("n", "]b", ':execute ":" . v:count . "bnext"<CR>', { silent = true, remap = false })
keymap.set("n", "[b", ':execute ":" . v:count . "bprevious"<CR>', { silent = true, remap = false })

-- Taking from here: https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
-- Allows running macros only on selected files.
keymap.set(
    "x",
    "@",
    ':<C-u>echo "@".getcmdline() | execute ":\'<,\'>normal @" . nr2char(getchar())<CR>',
    { silent = true, remap = false }
)

keymap.set("x", ".", ":normal .<CR>", { silent = true })

keymap.set("n", "L", "$", { silent = true })
keymap.set("v", "L", "$", { silent = true })

keymap.set("n", "H", "^", { silent = true })
keymap.set("v", "H", "^", { silent = true })

keymap.set("n", "Y", "y$", { silent = true })

-- Pressing <leader>ss will toggle and untoggle spell checking
keymap.set("n", "<leader>ss", ":setlocal spell!<CR>", { silent = true })

keymap.set("t", "<C-d>", "<PageDown>", { silent = true })
keymap.set("t", "<C-u>", "<PageUp>", { silent = true })

keymap.set("t", "<C-w><C-q>", "<C-\\><C-n>", { silent = true, remap = false })
keymap.set("t", "<C-w><C-h>", "<C-\\><C-n><C-w>h", { silent = true, remap = false })
keymap.set("t", "<C-w><C-j>", "<C-\\><C-n><C-w>j", { silent = true, remap = false })
keymap.set("t", "<C-w><C-k>", "<C-\\><C-n><C-w>k", { silent = true, remap = false })
keymap.set("t", "<C-w><C-l>", "<C-\\><C-n><C-w>l", { silent = true, remap = false })

-- }}}

-- Abbreviations {{{

cmd([[abbreviate langauge language]])
cmd([[abbreviate Langauge Language]])
cmd([[abbreviate lenght length]])
cmd([[abbreviate Lenght Length]])

if vim.o.loadplugins == true then
    cmd([[cnoreabbrev fgit FGit]])
    cmd([[cnoreabbrev git Git]])
    cmd([[cnoreabbrev gst Gstatus]])

    cmd([[cnoreabbrev fd Fd]])
    cmd([[cnoreabbrev rg Rg]])
    cmd([[cnoreabbrev ug Ug]])

    cmd([[cnoreabbrev frun FRun]])
    cmd([[cnoreabbrev fh Fhdo]])
end

cmd([[cnoreabbrev time Time]])
cmd([[cnoreabbrev bc Bclose]])

cmd(
    [[cnoreabbrev buffs@ <C-R>=luaeval("table.concat(require'vimrc.buffers'.get_buffer_names(), ' ')")<CR>]]
)

if vim.o.loadplugins == true then
    cmd([[cnoreabbrev head@ <C-R>=FugitiveHead()<CR>]])
end

-- }}}

-- Plugins {{{

-- nvim-treesitter {{{

if fn.exists("$VIMRC_TREESITTER_DISABLED") ~= 1 then
    g.vimrc_treesitter_filetypes = {
        "ada",
        "agda",
        "angular",
        "apex",
        "arduino",
        "asm",
        "astro",
        "authzed",
        "awk",
        "bash",
        "bass",
        "beancount",
        "bibtex",
        "bicep",
        "bitbake",
        "blade",
        "blueprint",
        "bp",
        "c",
        "c_sharp",
        "caddy",
        "cairo",
        "capnp",
        "chatito",
        "circom",
        "clojure",
        "cmake",
        "comment",
        "commonlisp",
        "cooklang",
        "corn",
        "cpon",
        "cpp",
        "css",
        "csv",
        "cuda",
        "cue",
        "cylc",
        "d",
        "dart",
        "desktop",
        "devicetree",
        "dhall",
        "diff",
        "disassembly",
        "djot",
        "dockerfile",
        "dot",
        "doxygen",
        "dtd",
        "earthfile",
        "ebnf",
        "editorconfig",
        "eds",
        "eex",
        "elixir",
        "elm",
        "elsa",
        "elvish",
        "embedded_template",
        "enforce",
        "erlang",
        "facility",
        "faust",
        "fennel",
        "fidl",
        "firrtl",
        "fish",
        "foam",
        "forth",
        "fortran",
        "fsh",
        "fsharp",
        "func",
        "fusion",
        "gap",
        "gaptst",
        "gdscript",
        "gdshader",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "gleam",
        "glimmer",
        "glimmer_javascript",
        "glimmer_typescript",
        "glsl",
        "gn",
        "gnuplot",
        "go",
        "goctl",
        "godot_resource",
        "gomod",
        "gosum",
        "gotmpl",
        "gowork",
        "gpg",
        "graphql",
        "gren",
        "groovy",
        "gstlaunch",
        "hack",
        "hare",
        "haskell",
        "haskell_persistent",
        "hcl",
        "heex",
        "helm",
        "hjson",
        "hlsl",
        "hlsplaylist",
        "hocon",
        "hoon",
        "html",
        "htmldjango",
        "http",
        "hurl",
        "hyprlang",
        "idl",
        "idris",
        "ini",
        "inko",
        "ipkg",
        "ispc",
        "janet_simple",
        "java",
        "javadoc",
        "javascript",
        "jinja",
        "jinja_inline",
        "jq",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "jsonnet",
        "julia",
        "just",
        "kcl",
        "kconfig",
        "kdl",
        "kotlin",
        "koto",
        "kusto",
        "lalrpop",
        "latex",
        "ledger",
        "leo",
        "linkerscript",
        "liquid",
        "liquidsoap",
        "llvm",
        "lua",
        "luadoc",
        "luap",
        "luau",
        "m68k",
        "make",
        "markdown",
        "markdown_inline",
        "matlab",
        "menhir",
        "mermaid",
        "meson",
        "mlir",
        "muttrc",
        "nasm",
        "nginx",
        "nickel",
        "nim",
        "nim_format_string",
        "ninja",
        "nix",
        "norg",
        "nqc",
        "nu",
        "objc",
        "objdump",
        "ocaml",
        "ocaml_interface",
        "ocamllex",
        "odin",
        "pascal",
        "passwd",
        "pem",
        "perl",
        "php",
        "php_only",
        "phpdoc",
        "pioasm",
        "po",
        "pod",
        "poe_filter",
        "pony",
        "powershell",
        "printf",
        "prisma",
        "problog",
        "prolog",
        "promql",
        "properties",
        "proto",
        "prql",
        "psv",
        "pug",
        "puppet",
        "purescript",
        "pymanifest",
        "python",
        "ql",
        "qmldir",
        "qmljs",
        "query",
        "r",
        "racket",
        "ralph",
        "rasi",
        "razor",
        "rbs",
        "re2c",
        "readline",
        "regex",
        "rego",
        "requirements",
        "rescript",
        "rnoweb",
        "robot",
        "robots",
        "roc",
        "ron",
        "rst",
        "ruby",
        "runescript",
        "rust",
        "scala",
        "scfg",
        "scheme",
        "scss",
        "sflog",
        "slang",
        "slim",
        "slint",
        "smali",
        "smithy",
        "snakemake",
        "solidity",
        "soql",
        "sosl",
        "sourcepawn",
        "sparql",
        "sql",
        "squirrel",
        "ssh_config",
        "starlark",
        "strace",
        "styled",
        "supercollider",
        "superhtml",
        "surface",
        "svelte",
        "sway",
        "swift",
        "sxhkdrc",
        "systemtap",
        "t32",
        "tablegen",
        "tact",
        "tcl",
        "teal",
        "templ",
        "tera",
        "terraform",
        "textproto",
        "thrift",
        "tiger",
        "tlaplus",
        "tmux",
        "todotxt",
        "toml",
        "tsv",
        "tsx",
        "turtle",
        "twig",
        "typescript",
        "typespec",
        "typoscript",
        "typst",
        "udev",
        "ungrammar",
        "unison",
        "usd",
        "uxntal",
        "v",
        "vala",
        "vento",
        "verilog",
        "vhdl",
        "vhs",
        "vim",
        "vimdoc",
        "vrl",
        "vue",
        "wgsl",
        "wgsl_bevy",
        "wing",
        "wit",
        "xcompose",
        "xml",
        "xresources",
        "yaml",
        "yang",
        "yuck",
        "zathurarc",
        "zig",
        "ziggy",
        "ziggy_schema",
    }
end

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
    require("sekme").setup {
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
    }
end

-- }}}

-- nvim-treesitter {{{

if vim.o.loadplugins == true and g.vimrc_treesitter_filetypes ~= nil then
    local treesitter_filetypes = vim.list_extend({}, g.vimrc_treesitter_filetypes)
    table.insert(treesitter_filetypes, "qml")

    local treesitter_fold_group =
        api.nvim_create_augroup("vimrc_plugin_nvim_treesitter", { clear = true })
    local treesitter_init_group =
        api.nvim_create_augroup("vimrc_plugin_nvim_treesitter_init", { clear = true })

    for _, ft in ipairs(treesitter_filetypes) do
        api.nvim_create_autocmd("FileType", {
            pattern = ft,
            callback = function(ev)
                vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.opt_local.foldmethod = "expr"

                if ft == "qml" then
                    vim.treesitter.start(ev.buf, "qmljs")
                else
                    vim.opt_local.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    vim.treesitter.start(ev.buf, ft)
                end
            end,
            group = treesitter_fold_group,
        })

        api.nvim_create_autocmd("FileType", {
            pattern = ft,
            callback = function()
                require("vimrc").setup_treesitter()
            end,
            group = treesitter_init_group,
        })
    end
end

-- }}}

-- firvish.nvim {{{

g.firvish_shell = "pwsh"
g.firvish_use_default_mappings = true

if vim.o.loadplugins then
    require("firvish.notifications").notify = function(msg, _, opts)
        opts.title = opts.title or "Neovim"
        local firvish = require("firvish.job_control")
        firvish.start_job {
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
        }
    end
end

-- }}}

-- comment.nvim {{{

if vim.o.loadplugins == true then
    require("Comment").setup { ignore = "^$" }

    local ft = require("Comment.ft")
    ft.qml = { "//%s", "/*%s*/" }
end

-- }}}

-- options.nvim {{{

if vim.o.loadplugins == true then
    local options = require("options")

    options.register_option {
        name = "qmllint_enabled",
        default = true,
        type_info = "boolean",
        source = "lsp",
        buffer_local = true,
    }
    options.register_option {
        name = "pylint_enabled",
        default = true,
        type_info = "boolean",
        source = "lsp",
        buffer_local = true,
    }
    options.register_option {
        name = "tags_completion_enabled",
        default = true,
        type_info = "boolean",
        source = "lsp",
        buffer_local = true,
    }
    options.register_option {
        name = "clean_trailing_whitespace",
        default = true,
        type_info = "boolean",
        source = "buffers",
        buffer_local = true,
    }
    options.register_option {
        name = "lsp_tagfunc_enabled",
        default = true,
        type_info = "boolean",
        source = "vimrc",
        global = true,
    }
    options.register_option {
        name = "clean_trailing_whitespace_limit",
        default = 0,
        type_info = "number",
        source = "buffers",
        buffer_local = true,
        description = "If the number of trailing white spaces below this number, they will be cleared automatically. Otherwise you will be prompted for each one.",
    }
    options.register_option {
        name = "highlight_trailing_whitespace",
        default = true,
        type_info = "boolean",
        source = "buffers",
        buffer_local = true,
    }
    options.register_option {
        name = "indentsize",
        default = 4,
        type_info = "number",
        source = "buffers",
        buffer_local = true,
    }
    options.register_option {
        name = "shell",
        default = "pwsh",
        type_info = "string",
        source = "options",
        global = true,
    }
    options.register_option {
        name = "scratchpad",
        default = false,
        type_info = "boolean",
        source = "options",
        buffer_local = true,
    }
    options.register_option {
        name = "todofenced",
        default = {},
        type_info = "table",
        source = "todo",
        buffer_local = true,
    }
    options.register_option {
        name = "minimal_buffer",
        default = false,
        type_info = "boolean",
        source = "buffers",
        buffer_local = true,
    }
    options.register_option {
        name = "lsp_context_enabled",
        default = true,
        type_info = "boolean",
        source = "buffers",
        buffer_local = true,
    }
    options.register_option {
        name = "lsp_virtual_text",
        default = false,
        type_info = "boolean",
        source = "lsp",
        buffer_local = false,
        description = "Enable virtual text for LSP globally.",
    }
    options.register_option {
        name = "lsp_completion_buffer_enabled",
        default = true,
        type_info = "boolean",
        source = "lsp",
        buffer_local = false,
        description = "Enable cmp-buffer completion source.",
    }
    options.register_option {
        name = "lsp_completion_path_enabled",
        default = true,
        type_info = "boolean",
        source = "lsp",
        buffer_local = false,
        description = "Enable cmp-path completion source.",
    }
end

-- }}}

-- cosmic_latte {{{

if vim.o.loadplugins == true then
    require("catppuccin").setup {
        flavour = "auto",
        background = {
            light = "latte",
            dark = "frappe",
        },
        term_colors = true,
        integrations = {
            cmp = false,
            gitsigns = false,
            nvimtree = false,
            treesitter = true,
            notify = false,
            mini = {
                enabled = false,
                indentscope_color = "",
            },
        },
        styles = {
            comments = { "italic" },
            strings = { "italic" },
            numbers = { "italic" },
        },
        highlight_overrides = {
            latte = function(latte)
                return {
                    Tag = { fg = latte.yellow },
                    StatusLineBranch = { fg = latte.mantle, bg = latte.rosewater },
                }
            end,
            all = function(colors)
                return {
                    Link = { fg = colors.blue, underline = true },
                    Tag = { fg = colors.peach },
                    StatusLineMode = { fg = colors.mantle, bg = colors.text },
                    StatusLineSpecialWindow = { fg = colors.base, bg = colors.pink },
                    StatusLineTerm = { fg = colors.text, bg = colors.base },
                    StatusLineTermNC = { fg = colors.text, bg = colors.surface2 },
                    StatusLineFilePath = { fg = colors.text, bg = colors.mantle },
                    StatusDiffFileSign = { fg = colors.pink, bg = colors.mantle },
                    StatusDiffFileSignNC = { fg = colors.pink, bg = colors.mantle },
                    StatusLineModified = { fg = colors.yellow, bg = colors.mantle },
                    StatusLineLspStatus = { fg = colors.yellow, bg = colors.mantle },
                    StatusLineRowColumn = { fg = colors.text, bg = colors.mantle },
                    StatusLineBranch = { fg = colors.mantle, bg = colors.maroon },
                    StatusLineError = { fg = colors.red, bg = colors.mantle },
                    StatusLineWarning = { fg = colors.blue, bg = colors.mantle },
                    StatusLineHint = { fg = colors.green, bg = colors.mantle },
                    StatusLineInfo = { fg = colors.flamingo, bg = colors.mantle },
                    ["@markup.quote.markdown"] = { link = "Comment" },
                    ["@markup.italic"] = { link = "Italic" },
                    ["@markup.strong.markdown_inline"] = { link = "Bold" },
                }
            end,
        },
    }
end

-- }}}

-- vim-fugitive {{{

if vim.o.loadplugins == true then
    keymap.set("n", "<C-f>o", ":Git<CR>", { silent = true })
    keymap.set("n", "<C-f>z", ":bd fugitive:*.git<CR>", { silent = true })
end

-- }}}

-- {{{

if vim.o.loadplugins == true then
    require("dropbar").setup {
        bar = {
            sources = function(buf, _)
                local sources = require("dropbar.sources")
                local utils = require("dropbar.utils")
                if vim.bo[buf].ft == "markdown" then
                    return { sources.markdown }
                end
                if vim.bo[buf].buftype == "terminal" then
                    return { sources.terminal }
                end
                return { utils.source.fallback { sources.lsp, sources.treesitter } }
            end,
        },
    }
end

-- }}}

-- vim-matchup {{{

if vim.o.loadplugins == true then
    g.matchup_matchparen_offscreen = { method = "popup" }
end

-- }}}

-- zig.vim {{{

g.zig_fmt_autosave = false

-- }}}

-- vim-dirvish {{{

vim.g.dirvish_mode = ":sort ,^.*[\\/],"

-- }}}

-- nvim-gdb {{{

vim.g.nvimgdb_disable_start_keymaps = true
vim.g.nvimgdb_config_override = {
    key_until = "<leader>dr",
    key_continue = "<leader>dc",
    key_next = "<leader>dn",
    key_step = "<leader>ds",
    key_breakpoint = "<leader>db",
    key_frameup = "<leader>du",
    key_framedown = "<leader>dd",
    key_eval = "<leader>dk",
}

-- }}}

-- }}}

-- Local Plugins {{{

-- Buffers, Jira, Time {{{

api.nvim_create_user_command("DiffWithSaved", function(_)
    local filetype = vim.opt_local.filetype
    vim.cmd([[vnew | r # | normal! 1Gdd]])
    vim.opt_local.buftype = "nofile"
    vim.opt_local.bufhidden = "wipe"
    vim.opt_local.buflisted = false
    vim.opt_local.swapfile = false
    vim.opt_local.readonly = true
    vim.opt_local.filetype = filetype
    vim.cmd([[diffthis]])
    vim.cmd([[wincmd p]])
    vim.cmd([[diffthis]])
end, { bar = true })

if vim.o.loadplugins then
    api.nvim_create_user_command(
        "FGit",
        ":lua require'vimrc'.run_git(<q-args>, <q-bang> ~= '!')",
        { complete = "customlist,fugitive#Complete", nargs = "*", range = true, bar = true }
    )
end

api.nvim_create_user_command("Time", function(_)
    cmd([[echohl IncSearch | echo "Time: " . strftime('%b %d %A, %H:%M') | echohl NONE']])
end, { bar = true })

-- }}}

-- todo {{{

if vim.o.loadplugins == true then
    cmd([[augroup vimrc_plugin_todo_init]])
    cmd([[au!]])
    cmd([[autocmd FileType todo ++once :lua require"vimrc.todo".init()]])
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
    keymap.set("n", "gh", ":call help#search_docs()<CR>", { silent = true })
    cmd([[command! -nargs=1 Search :call help#search_docs(<f-args>)]])
end

-- }}}

-- Sort {{{

cmd(
    [[command -complete=customlist,custom_sort#sort_command_completion -range -nargs=1 -bar Sort :call custom_sort#sort(<f-args>, <line1>, <line2>)]]
)

-- }}}

-- QuickFix {{{

keymap.set("n", "<C-q>z", ":cclose<CR>", { silent = true })
keymap.set(
    "n",
    "<C-q>o",
    ":botright copen | if exists('g:vimrc_quickfix_size_cache') && has_key(g:vimrc_quickfix_size_cache, tabpagenr()) | execute 'resize ' . g:vimrc_quickfix_size_cache[tabpagenr()] | endif<CR>",
    { silent = true }
)
keymap.set(
    "n",
    "<C-q>lo",
    ":botright lopen | if exists('g:vimrc_quickfix_size_cache') && has_key(g:vimrc_quickfix_size_cache, tabpagenr()) | execute 'resize ' . g:vimrc_quickfix_size_cache[tabpagenr()] | endif<CR>",
    { silent = true }
)
keymap.set("n", "<C-q>lz", ":lclose<CR>", { silent = true })

-- }}}

-- Text Objects {{{

if vim.o.loadplugins == true then
    require("vimrc.textobjects").init()
end

-- }}}

-- Buffers {{{

require("vimrc.buffers").init()

keymap.set(
    "v",
    "<leader>s",
    ":call buffers#visual_selection('search', '')<CR>",
    { silent = true, remap = false }
)
keymap.set(
    "v",
    "<leader>r",
    ":call buffers#visual_selection('replace', '')<CR>",
    { silent = true, remap = false }
)

keymap.set(
    "n",
    "<leader>cc",
    ":lua require'vimrc.buffers'.toggle_colorcolumn(vim.api.nvim_win_get_cursor(0)[2] + 1)<CR>",
    { silent = true, remap = false }
)
keymap.set(
    "n",
    "<leader>cd",
    ":lua require'vimrc.buffers'.toggle_colorcolumn(-1)<CR>",
    { silent = true, remap = false }
)

cmd(
    [[command! CleanTrailingWhiteSpace :lua require"vimrc.buffers".clean_trailing_spaces(vim.api.nvim_get_current_buf())]]
)

cmd([[command! Bclose :lua require"vimrc.buffers".close()]])
cmd([[command! -nargs=1 -bang Bdeletes :call buffers#wipe_matching('<args>', <q-bang>)]])
cmd([[command! Bdnonexisting :call buffers#wipe_nonexisting_files()]])

cmd([[augroup vimrc_plugin_buffers]])
cmd([[au!]])
cmd(
    [[autocmd BufWritePre *.py,*.cpp,*.qml,*.js,*.txt,*.json,*.html,*.lua :lua require"vimrc.buffers".clean_trailing_spaces(vim.api.nvim_get_current_buf())]]
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

require("vimrc.terminal").setup()

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

local augroup_vimrc_init = api.nvim_create_augroup("vimrc_init", { clear = true })
if vim.o.loadplugins == true then
    api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
        pattern = "*.http",
        group = augroup_vimrc_init,
        callback = function(_)
            if g.vimrc_rest_nvim_loaded == nil then
                cmd([[packadd rest.nvim]])
                require("vimrc").setup_rest_nvim()
                g.vimrc_rest_nvim_loaded = true
            end
        end,
    })

    api.nvim_create_autocmd({ "BufWinEnter" }, {
        pattern = "*.md",
        group = augroup_vimrc_init,
        callback = function(_)
            require("options").set_modeline(vim.api.nvim_get_current_buf())
        end,
    })
end

api.nvim_create_autocmd({ "TextYankPost" }, {
    pattern = "*",
    group = augroup_vimrc_init,
    callback = function(_)
        vim.highlight.on_yank { on_visual = false, higroup = "IncSearch", timeout = 150 }
    end,
})

api.nvim_create_autocmd({ "VimEnter" }, {
    pattern = "*",
    group = augroup_vimrc_init,
    callback = function(_)
        require("vimrc").create_custom_nvim_server()
        if vim.o.loadplugins == true then
            if opt.background == "dark" then
                cmd([[colorscheme catppuccin-frappe]])
            else
                cmd([[colorscheme catppuccin-latte]])
            end
        end
    end,
})

api.nvim_create_autocmd({ "VimLeavePre" }, {
    pattern = "*",
    group = augroup_vimrc_init,
    callback = function(_)
        if fn.exists("$AW_AUTO_SESSION") ~= 1 then
            return
        end

        if fn.exists("$AW_SESSION_DIR") == 1 then
            cmd([[execute "mksession! " . expand("$AW_SESSION_DIR/session.vim")]])
        else
            cmd([[mksession! session.vim]])
        end
    end,
})

api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = "*",
    group = augroup_vimrc_init,
    callback = function(_)
        -- Return to last edit position when opening files (You want this!)
        if fn.line("'\"") > 1 and fn.line("'\"") <= fn.line("$") then
            cmd([[execute "normal! g'\""]])
        end
    end,
})

api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*",
    group = augroup_vimrc_init,
    callback = function(_)
        require("vimrc").load_dictionary()
    end,
})

api.nvim_create_autocmd({ "OptionSet" }, {
    pattern = "diff",
    group = augroup_vimrc_init,
    callback = function(opts)
        local bufnr = opts.buf
        if vim.wo.diff then
            keymap.set("n", "<leader>dgh", ":diffget \\\\2<CR>", { silent = true, buffer = bufnr })
            keymap.set("n", "<leader>dgl", ":diffget \\\\3<CR>", { silent = true, buffer = bufnr })
        else
            keymap.del("n", "<leader>dgh", { buffer = bufnr })
            keymap.del("n", "<leader>dgl", { buffer = bufnr })
        end
    end,
})

if fn.filereadable(tostring(fn.expand("~/.vimrc"))) == 1 then
    cmd("source ~/.vimrc")
end

if fn.filereadable(tostring(fn.expand("~/.nvim.lua"))) == 1 then
    cmd("source ~/.nvim.lua")
end

-- vim: foldmethod=marker
