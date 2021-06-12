local map = require"vimrc".map
vim.wo.cursorline = true

map("n", "]dp", ":call search('^dap>', 'W')<CR>", {silent = true, buffer=true})
map("n", "[dp", "call search('^dap>', 'Wb')<CR>", {silent = true, buffer=true})
