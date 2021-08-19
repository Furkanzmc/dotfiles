if vim.b.vimrc_did_firvish == true then return end

vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.colorcolumn = ""

vim.opt_local.cursorline = true
vim.opt_local.signcolumn = "no"

vim.b.vimrc_did_firvish = true
