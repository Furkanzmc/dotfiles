if vim.b.vimrc_did_dirvish == true then return end

local map = require"futils".map
local bufnr = vim.api.nvim_get_current_buf()

if vim.g.vimrc_dirvish_virtual_text_prefix == nil then
    vim.g.vimrc_dirvish_virtual_text_prefix = "> "
end

if vim.fn.executable("qlmanage") then
    map("n", "L", ':call jobstart(["qlmanage", "-p", getline(".")])<CR>',
        {silent = true, buffer = bufnr})
end

map("n", "S",
    ':lua require"vimrc.dirvish".show_status(1, vim.fn.line("$"))<CR>',
    {silent = true, buffer = bufnr})
map("v", "S",
    ':lua require"vimrc.dirvish".show_status(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
    {silent = true, buffer = bufnr})
map("n", "C", ':lua require"vimrc.dirvish".toggle_conceal()<CR>',
    {silent = true, buffer = bufnr})

map("n", "F", ':noautocmd Sort -folder-first | setlocal conceallevel=2<CR>',
    {silent = true, buffer = bufnr})
map("v", "F", ':noautocmd Sort -folder-first | setlocal conceallevel=2<CR>',
    {silent = true, buffer = bufnr})

require"vimrc.dirvish".init()
vim.b.vimrc_did_dirvish = true
