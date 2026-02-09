if vim.b.did_ftp == true then
    return
end

vim.opt_local.textwidth = 80
vim.opt_local.signcolumn = "no"
vim.opt_local.winbar = ""
vim.opt_local.commentstring = "# %s"
