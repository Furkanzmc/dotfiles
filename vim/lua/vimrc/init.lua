local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local utils = require "vimrc.utils"
local M = {}

function M.init_paq()
    cmd 'packadd paq-nvim'
    local paq = require'paq-nvim'.paq

    paq 'sheerun/vim-polyglot'
    paq 'tpope/vim-commentary'
    paq 'tpope/vim-fugitive'
    paq 'machakann/vim-sandwich'
    paq 'furkanzmc/cosmic_latte'
    paq 'justinmk/vim-dirvish'
    paq 'Furkanzmc/firvish.nvim'
    paq 'neovim/nvim-lspconfig'
    paq 'tmsvg/pear-tree'

    -- Optional {{{

    paq {'savq/paq-nvim', opt = true}
    paq {'vim-scripts/SyntaxRange', opt = true}
    paq {'majutsushi/tagbar', opt = true}
    paq {'masukomi/vim-markdown-folding', opt = true}
    paq {'junegunn/goyo.vim', opt = true}
    paq {'mfussenegger/nvim-dap', opt = true}

    paq {'rust-lang/rust.vim', opt = true}
    paq {'nvim-treesitter/nvim-treesitter', opt = true}
    paq {
        'furkanzmc/nvim-http',
        opt = true,
        hook = fn['remote#host#UpdateRemotePlugins']
    }

    -- }}}
end

function M.setup_treesitter()
    if fn.exists(":TSInstall") == 1 then return end

    cmd [[packadd nvim-treesitter]]
    require'nvim-treesitter.configs'.setup {
        ensure_installed = {'python', 'html', 'cpp', 'vue', 'json'},
        highlight = {enable = true},
        refactor = {highlight_definitions = {enable = true}}
    }

    cmd [[augroup plugin_nvim_treesitter]]
    cmd [[au!]]
    cmd [[augroup END]]
end

function M.create_custom_nvim_server()
    local pid = tostring(fn.getpid())
    local socket_name = ""
    if fn.has("win32") == 1 then
        socket_name = '\\\\.\\pipe\\nvim-' .. pid
    else
        socket_name =
            fn.expand('~/.dotfiles/vim/temp_dirs/servers/nvim') .. pid ..
                '.sock'
    end

    fn.serverstart(socket_name)
end

function M.load_dictionary()
    if b.vimrc_dictionary_loaded ~= nil then return end

    local search_directories = g.vimrc_dictionary_paths or {}
    table.insert(search_directories, "~/.dotfiles/vim/dictionary/")

    local files = fn.globpath(fn.expand(fn.join(search_directories, ",")),
                              '\\(' .. bo.filetype .. '_*\\|' .. bo.filetype ..
                                  '\\).dictionary')
    files = fn.split(files, '\n')
    if #files == 0 then return end

    for _, file_path in pairs(files) do
        cmd("setlocal dictionary+=" .. file_path)
    end

    b.vimrc_dictionary_loaded = true
end

function M.setup_white_space_highlight(bufnr)
    if b.vimrc_trailing_white_space_highlight_enabled then return end

    local excluded_filetypes = {"qf"}

    if bo.filetype == "" or table.index_of(excluded_filetypes, bo.filetype) ~=
        -1 then return end

    cmd("augroup trailing_white_space_highlight_buffer_" .. bufnr)
    cmd [[autocmd! * <buffer>]]
    cmd [[autocmd BufWinEnter <buffer> match TrailingWhiteSpace /\s\+$/]]
    cmd [[autocmd InsertEnter <buffer> match TrailingWhiteSpace /\s\+\%#\@<!$/]]
    cmd [[autocmd InsertLeave <buffer> match TrailingWhiteSpace /\s\+$/]]
    cmd [[autocmd BufWinLeave <buffer> call clearmatches()]]
    cmd [[augroup END]]

    b.vimrc_trailing_white_space_highlight_enabled = true
end

function M.run_git(args, is_background_job)
    local firvish = require"firvish.job_control"

    local cmd = {"git"}
    table.extend(cmd, fn.split(args, " "))
    firvish.start_job({
        cmd=cmd,
        filetype="job-output",
        title="Git",
        is_background_job=is_background_job,
        cwd=vim.fn.FugitiveGitDir(),
        listed=true,
    })
end

return M

-- vim: foldmethod=marker
