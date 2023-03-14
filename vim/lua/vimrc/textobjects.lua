local vim = vim
local keymap = vim.keymap
local fn = vim.fn
local cmd = vim.cmd
local M = {}

function M.url_text_object()
    local url_regex =
        "\\(https\\|http\\)\\?:\\/\\/\\(\\w\\+\\(:\\w\\+\\)\\?@\\)\\?\\([A-Za-z][-_0-9A-Za-z]*\\.\\)\\{1,}\\(\\w\\{2,}\\.\\?\\)\\{1,}\\(:[0-9]\\{1,5}\\)\\?\\S*"
    local linenr = fn.line(".")

    if fn.search(url_regex, "ceW", linenr) ~= 0 then
        cmd([[normal v]])
        fn.search(url_regex, "bcW", linenr)
    end
end

function M.number_text_object()
    local url_regex = "[0-9]\\+"
    local linenr = fn.line(".")

    if fn.search(url_regex, "ceW", linenr) ~= 0 then
        cmd([[normal v]])
        fn.search(url_regex, "bcW", linenr)
    end
end

function M.fence_text_object(opt)
    local fence_begin = "^```\\w\\+$"
    local fence_end = "^```"

    if fn.search(fence_end, "ceW") ~= 0 then
        if opt.inside then
            cmd([[normal kV]])
        else
            cmd([[normal V]])
        end

        fn.search(fence_begin, "cbW", linenr)

        if opt.inside then
            cmd([[normal j]])
        end
    end
end

function M.init()
    -- URL text object.
    keymap.set(
        "x",
        "iu",
        ":<C-u>lua require'vimrc.textobjects'.url_text_object()<CR>",
        { silent = true, remap = false }
    )
    keymap.set("o", "iu", ":<C-u>normal viu<CR>", { silent = true, remap = false })

    -- Line text objects.
    keymap.set("x", "il", "g_o^", { silent = true, remap = false })
    keymap.set("o", "il", ":<C-u>normal vil<CR>", { silent = true, remap = false })

    -- Number
    keymap.set(
        "x",
        "in",
        ":<C-u>lua require'vimrc.textobjects'.number_text_object()<CR>",
        { silent = true, remap = false }
    )
    keymap.set("o", "in", ":<C-u>normal viu<CR>", { silent = true, remap = false })

    -- Code Fence
    keymap.set(
        "x",
        "i`",
        ":<C-u>lua require'vimrc.textobjects'.fence_text_object({inside=true})<CR>",
        { silent = true, remap = false }
    )
    keymap.set("o", "i`", ":<C-u>normal viu<CR>", { silent = true, remap = false })

    keymap.set(
        "x",
        "a`",
        ":<C-u>lua require'vimrc.textobjects'.fence_text_object({around=true})<CR>",
        { silent = true, remap = false }
    )
    keymap.set("o", "a`", ":<C-u>normal vau<CR>", { silent = true, remap = false })
end

return M

-- vim: foldmethod=marker
