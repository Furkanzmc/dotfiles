local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local utils = require "vimrc.utils"
local M = {}

local function init_nvim_colorizer(bufnr)
    cmd [[command! EnableNvimColorizer :lua require"vimrc".enable_nvim_colorizer(vim.api.nvim_get_current_buf())]]
end

function M.init_paq()
    if vim.o.loadplugins == false then return end

    cmd [[packadd paq-nvim]]

    local paq = require'paq-nvim'.paq

    paq 'terrortylor/nvim-comment'
    paq 'tpope/vim-fugitive'
    paq 'machakann/vim-sandwich'
    paq 'furkanzmc/cosmic_latte'
    paq 'justinmk/vim-dirvish'
    paq 'Furkanzmc/firvish.nvim'
    paq 'neovim/nvim-lspconfig'
    paq 'tmsvg/pear-tree'

    -- Optional {{{

    paq {'sheerun/vim-polyglot', opt = true}
    paq {'savq/paq-nvim', opt = true}
    paq {'vim-scripts/SyntaxRange', opt = true}
    paq {'majutsushi/tagbar', opt = true}
    paq {'masukomi/vim-markdown-folding', opt = true}
    paq {'mfussenegger/nvim-dap', opt = true}
    paq {'rust-lang/rust.vim', opt = true}
    paq {'nvim-treesitter/nvim-treesitter', opt = true}
    paq {
        'furkanzmc/nvim-http',
        opt = true,
        hook = fn['remote#host#UpdateRemotePlugins']
    }

    paq {'Furkanzmc/nvim-qt', opt = true}
    paq {'sindrets/diffview.nvim', opt = true}
    paq {'norcalli/nvim-colorizer.lua', opt = true}
    paq {'lifepillar/vim-colortemplate', opt = true}

    -- }}}
end

function M.setup_treesitter()
    if vim.o.loadplugins == false then return end

    assert(fn.exists(":TSInstall") == 0)

    cmd [[packadd nvim-treesitter]]

    local config = require 'nvim-treesitter.configs'
    config.setup {
        ensure_installed = g.polyglot_disabled,
        highlight = {enable = true},
        indent = {enabled = true},
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "gis",
                node_incremental = "gni",
                node_decremental = "gnd",
                scope_incremental = "gsi"
            }
        }
    }

    cmd [[augroup plugin_nvim_treesitter_init]]
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

function M.run_git(args, is_background_job)
    local firvish = require "firvish.job_control"

    local cmd = {"git"}
    table.extend(cmd, fn.split(args, " "))
    firvish.start_job({
        cmd = cmd,
        filetype = "job-output",
        title = "Git",
        is_background_job = is_background_job,
        cwd = vim.fn.FugitiveGitDir(),
        listed = true
    })
end

function M.enable_nvim_colorizer(bufnr)
    require'colorizer'.setup()
    cmd("augroup nvim_colorizer_buf_" .. bufnr)
    cmd [[ColorizerAttachToBuffer]]
    cmd [[au!]]
    cmd("autocmd FileType <buffer=" .. bufnr ..
            "> lua require'colorizer'.setup()")
    cmd [[augroup END]]
    cmd [[command! -buffer DisableNvimColorizer :lua require"vimrc".disable_nvim_colorizer(vim.api.nvim_get_current_buf())]]
end

function M.disable_nvim_colorizer(bufnr)
    cmd("augroup nvim_colorizer_buf_" .. bufnr)
    cmd [[au!]]
    cmd [[augroup END]]
    cmd [[delcommand DisableNvimColorizer]]
    cmd [[ColorizerDetachFromBuffer]]
end

function M.on_source_post()
    local file_path = fn.expand("<afile>")
    if string.match(file_path, "diffvim.vim") ~= nil then
        require'diffview'.setup {file_panel = {use_icons = false}}
    elseif string.match(file_path, "colorizer.vim") ~= nil then
        init_nvim_colorizer()
    end
end

function M.map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    if opts.buffer ~= nil then
        assert(type(opts.buffer) == "number")

        local bufnr = opts.buffer
        options.buffer = nil
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, options)
    else
        vim.api.nvim_set_keymap(mode, lhs, rhs, options)
    end
end

return M

-- vim: foldmethod=marker filetype=lua
