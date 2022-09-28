if vim.b.did_ftp == true then
    return
end

vim.opt_local.keywordprg = ":ZkHover -preview"
vim.opt_local.signcolumn = "no"
vim.opt_local.showbreak = "                       "
