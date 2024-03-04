if vim.b.did_ftp == true then
    return
end

vim.bo.commentstring = "#\\ %s"
vim.opt_local.cursorline = true
vim.opt_local.cursorlineopt = "both"
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"
