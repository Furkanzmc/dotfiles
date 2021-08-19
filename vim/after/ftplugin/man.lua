if vim.b.vimrc_did_man == true then return end

vim.opt_local.cursorline = true
vim.opt_local.number = false
vim.opt_local.relativenumber = false

vim.opt_local.statusline = ""
vim.o.laststatus = 0

vim.b.vimrc_did_man = true
