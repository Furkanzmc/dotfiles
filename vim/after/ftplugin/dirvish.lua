if vim.b.did_ftp == true then
    return
end

local map = require("vimrc").map
local bufnr = vim.api.nvim_get_current_buf()

vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false

if vim.g.vimrc_dirvish_virtual_text_prefix == nil then
    vim.g.vimrc_dirvish_virtual_text_prefix = "> "
end

if vim.fn.executable("qlmanage") == 1 then
    map(
        "n",
        "<leader>l",
        ':call jobstart(["qlmanage", "-p", getline(".")])<CR>',
        { silent = true, buffer = bufnr }
    )
end

map(
    "n",
    "S",
    ':lua require"vimrc.dirvish".show_status(1, vim.fn.line("$"))<CR>',
    { silent = true, buffer = bufnr }
)
map(
    "v",
    "S",
    ':lua require"vimrc.dirvish".show_status(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
    { silent = true, buffer = bufnr }
)
map("n", "C", ':lua require"vimrc.dirvish".toggle_conceal()<CR>', {
    silent = true,
    buffer = bufnr,
})

map(
    "n",
    "F",
    ":noautocmd Sort -folder-first | setlocal conceallevel=2<CR>",
    { silent = true, buffer = bufnr }
)
map(
    "v",
    "F",
    ":noautocmd Sort -folder-first | setlocal conceallevel=2<CR>",
    { silent = true, buffer = bufnr }
)

map("n", "Y", ":normal! 0y$<CR>", {
    silent = true,
    buffer = bufnr,
})

require("vimrc.dirvish").init()
