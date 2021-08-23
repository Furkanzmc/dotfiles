if vim.b.vimrc_did_dap == true then return end

local map = require"futils".map
local bufnr = vim.api.nvim_get_current_buf()
vim.opt_local.cursorline = true

map("n", "]dp", ":call search('^dap>', 'W')<CR>",
    {silent = true, buffer = bufnr})
map("n", "[dp", "call search('^dap>', 'Wb')<CR>",
    {silent = true, buffer = bufnr})

vim.b.vimrc_did_dap = true
