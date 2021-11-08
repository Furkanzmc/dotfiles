if vim.b.did_ftp == true then
    return
end

vim.wo.foldmethod = "indent"
vim.opt_local.cursorline = false
vim.opt_local.cursorcolumn = false
