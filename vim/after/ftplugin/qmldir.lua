if vim.b.did_ftp == true then
    return
end

vim.bo.commentstring = "#\\ %s"
vim.bo.suffixesadd = ".qml"
vim.opt_local.cursorline = false
vim.opt_local.cursorcolumn = false
