if vim.b.did_ftp == true then
    return
end

vim.bo.commentstring = "#\\ %s"
vim.wo.foldmethod = "indent"
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"
vim.opt_local.winbar = ""
