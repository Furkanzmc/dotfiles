local map = require"vimrc".map
vim.wo.cursorline = true

map("n", "]dp", ":call search('^dap>', 'W')<CR>",
    {silent = true, buffer = vim.api.nvim_get_current_buf()})
map("n", "[dp", "call search('^dap>', 'Wb')<CR>",
    {silent = true, buffer = vim.api.nvim_get_current_buf()})
