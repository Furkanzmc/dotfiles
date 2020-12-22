local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local M = {}

function M.init_paq()
    cmd 'packadd paq-nvim'
    local paq = require'paq-nvim'.paq

    paq {'savq/paq-nvim', opt = true}

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

    paq {'vim-scripts/SyntaxRange', opt = true}
    paq {'majutsushi/tagbar', opt = true}
    paq {'masukomi/vim-markdown-folding', opt = true}
    paq {'junegunn/goyo.vim', opt = true}
    paq {
        'sakhnik/nvim-gdb',
        opt = true,
        hook = fn['remote#host#UpdateRemotePlugins']
    }
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

return M
