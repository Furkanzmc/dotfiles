if vim.b.did_ftp == true then
    return
end

vim.wo.foldmethod = "marker"
vim.opt_local.cursorline = false
vim.opt_local.textwidth = 100
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"
