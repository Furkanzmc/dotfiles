if vim.b.did_ftp == true then
    return
end

vim.bo.cindent = false
vim.bo.suffixesadd = ".js,.jsx"
vim.opt_local.cursorline = false
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"
