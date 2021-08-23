local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local M = {}

function M.url_text_object()
    local url_regex =
        '\\(https\\|http\\)\\?:\\/\\/\\(\\w\\+\\(:\\w\\+\\)\\?@\\)\\?\\([A-Za-z][-_0-9A-Za-z]*\\.\\)\\{1,}\\(\\w\\{2,}\\.\\?\\)\\{1,}\\(:[0-9]\\{1,5}\\)\\?\\S*'
    local linenr = fn.line('.')

    if fn.search(url_regex, 'ceW', linenr) ~= 0 then
        cmd [[normal v]]
        fn.search(url_regex, 'bcW', linenr)
    end
end

function M.number_text_object()
    local url_regex = '[0-9]\\+'
    local linenr = fn.line('.')

    if fn.search(url_regex, 'ceW', linenr) ~= 0 then
        cmd [[normal v]]
        fn.search(url_regex, 'bcW', linenr)
    end
end

function M.fence_text_object(opt)
    local fence_begin = '^```\\w\\+$'
    local fence_end = '^```'

    if fn.search(fence_end, 'ceW') ~= 0 then
        if opt.inside then
            cmd [[normal kV]]
        else
            cmd [[normal V]]
        end

        fn.search(fence_begin, 'cbW', linenr)

        if opt.inside then cmd [[normal j]] end
    end
end

function M.init()
    local map = require"futils".map

    -- URL text object.
    map("x", "iu", ":<C-u>lua require'vimrc.textobjects'.url_text_object()<CR>",
        {silent = true, noremap = true})
    map("o", "iu", ":<C-u>normal viu<CR>", {silent = true, noremap = true})

    -- Line text objects.
    map("x", "il", "g_o^", {silent = true, noremap = true})
    map("o", "il", ":<C-u>normal vil<CR>", {silent = true, noremap = true})

    -- Number
    map("x", "in",
        ":<C-u>lua require'vimrc.textobjects'.number_text_object()<CR>",
        {silent = true, noremap = true})
    map("o", "in", ":<C-u>normal viu<CR>", {silent = true, noremap = true})

    -- Code Fence
    map("x", "i`",
        ":<C-u>lua require'vimrc.textobjects'.fence_text_object({inside=true})<CR>",
        {silent = true, noremap = true})
    map("o", "i`", ":<C-u>normal viu<CR>", {silent = true, noremap = true})

    map("x", "a`",
        ":<C-u>lua require'vimrc.textobjects'.fence_text_object({around=true})<CR>",
        {silent = true, noremap = true})
    map("o", "a`", ":<C-u>normal vau<CR>", {silent = true, noremap = true})
end

return M

-- vim: foldmethod=marker
