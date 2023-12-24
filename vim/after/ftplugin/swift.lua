if vim.b.did_ftp == true then
    return
end

vim.opt_local.signcolumn = "yes"
vim.opt_local.cursorline = false
vim.opt_local.cursorcolumn = false
