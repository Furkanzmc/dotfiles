if vim.b.did_ftp == true then
    return
end

vim.wo.number = false
vim.wo.relativenumber = false
vim.opt_local.cursorline = false
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"
vim.opt_local.winbar = ""
