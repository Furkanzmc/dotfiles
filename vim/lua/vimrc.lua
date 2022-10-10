local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local api = vim.api
local utils = require("vimrc.utils")
local M = {}

local function init_nvim_colorizer()
    cmd(
        [[command! EnableNvimColorizer :lua require"vimrc".enable_nvim_colorizer(vim.api.nvim_get_current_buf())]]
    )
end

function M.map(mode, lhs, rhs, opts)
    local options = {}
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    if opts.buffer ~= nil then
        assert(type(opts.buffer) == "number")

        local bufnr = opts.buffer
        options.buffer = nil
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, options)
    else
        vim.api.nvim_set_keymap(mode, lhs, rhs, options)
    end
end

function M.setup_treesitter()
    if vim.o.loadplugins == false or fn.exists("$VIMRC_TREESITTER_DISABLED") == 1 then
        return
    end

    assert(fn.exists(":TSInstall") == 0, "TreeSitter is already configured.")

    cmd([[packadd nvim-treesitter]])

    local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

    parser_configs.http = {
        install_info = {
            url = "https://github.com/NTBBloodbath/tree-sitter-http",
            files = { "src/parser.c" },
            branch = "main",
        },
    }

    local config = require("nvim-treesitter.configs")
    config.setup({
        ensure_installed = g.vimrc_treesitter_filetypes,
        highlight = { enable = true },
        indent = { enabled = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "gis",
                node_incremental = "gni",
                node_decremental = "gnd",
                scope_incremental = "gsi",
            },
        },
        matchup = { enable = true },
    })

    cmd([[augroup vimrc_plugin_nvim_treesitter_init]])
    cmd([[au!]])
    cmd([[augroup END]])
end

function M.setup_rest_nvim()
    require("rest-nvim").setup({
        result_split_horizontal = false,
        skip_ssl_verification = false,
        highlight = { enabled = true, timeout = 150 },
        jump_to_request = false,
    })

    local map = require("vimrc").map
    map(
        "n",
        "<leader>tt",
        "<Plug>RestNvim",
        { silent = true, buffer = vim.api.nvim_get_current_buf() }
    )
    map(
        "n",
        "<leader>tp",
        "<Plug>RestNvimPreview",
        { silent = true, buffer = vim.api.nvim_get_current_buf() }
    )
end

function M.create_custom_nvim_server()
    local pid = tostring(fn.getpid())
    local socket_name = ""
    if fn.has("win32") == 1 then
        socket_name = "\\\\.\\pipe\\nvim-" .. pid
    else
        socket_name = fn.expand("~/.dotfiles/vim/temp_dirs/servers/nvim") .. pid .. ".sock"
    end

    fn.serverstart(socket_name)
end

function M.load_dictionary()
    if b.vimrc_dictionary_loaded ~= nil then
        return
    end

    local search_directories = g.vimrc_dictionary_paths or {}
    table.insert(search_directories, "~/.dotfiles/vim/dictionary/")

    local files = fn.globpath(
        fn.expand(fn.join(search_directories, ",")),
        "\\(" .. bo.filetype .. "_*\\|" .. bo.filetype .. "\\).dictionary"
    )
    files = fn.split(files, "\n")
    if #files == 0 then
        return
    end

    for _, file_path in pairs(files) do
        cmd("setlocal dictionary+=" .. file_path)
    end

    b.vimrc_dictionary_loaded = true
end

function M.run_git(args, is_background_job)
    local firvish = require("firvish.job_control")

    local cmd = fn.split(args, " ")
    table.insert(cmd, 1, "git")
    firvish.start_job({
        cmd = cmd,
        filetype = "job-output",
        title = "Git",
        is_background_job = is_background_job,
        cwd = vim.fn.FugitiveGitDir(),
        listed = true,
    })
end

function M.enable_nvim_colorizer(bufnr)
    require("colorizer").setup()
    cmd("augroup nvim_colorizer_buf_" .. bufnr)
    cmd([[ColorizerAttachToBuffer]])
    cmd([[au!]])
    cmd("autocmd FileType <buffer=" .. bufnr .. "> lua require'colorizer'.setup()")
    cmd([[augroup END]])
    cmd(
        [[command! -buffer DisableNvimColorizer :lua require"vimrc".disable_nvim_colorizer(vim.api.nvim_get_current_buf())]]
    )
end

function M.disable_nvim_colorizer(bufnr)
    cmd("augroup nvim_colorizer_buf_" .. bufnr)
    cmd([[au!]])
    cmd([[augroup END]])
    cmd([[delcommand DisableNvimColorizer]])
    cmd([[ColorizerDetachFromBuffer]])
end

function M.on_source_post()
    local file_path = fn.expand("<afile>")
    if string.match(file_path, "colorizer.vim") ~= nil then
        init_nvim_colorizer()
    end
end

-- Creates a diffsplit between two remote files. I could not find a way to do this with Gdiffsplit
-- Expects that Diff-Branches Powershell command was used.
function M.gdiffsplit(source_branch, target_branch)
    cmd("Gdiffsplit! " .. target_branch)
    vim.b[api.nvim_get_current_buf()].vimrc_buffer_type = "vimrc_diffsplit"
    vim.b[api.nvim_get_current_buf()].vimrc_diffsplit_branch = source_branch

    cmd([[normal p]])
    vim.b[api.nvim_get_current_buf()].vimrc_buffer_type = "vimrc_diffsplit"
    vim.b[api.nvim_get_current_buf()].vimrc_diffsplit_branch = target_branch

    cmd([[normal p]])
end

return M

-- vim: foldmethod=marker
