if vim.b.did_ftp == true then
    return
end

vim.opt_local.cindent = false
vim.opt_local.suffixesadd = ".java"
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"
