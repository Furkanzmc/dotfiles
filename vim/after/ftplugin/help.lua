if vim.b.did_ftp == true then
    return
end

vim.wo.signcolumn = "no"
vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false
