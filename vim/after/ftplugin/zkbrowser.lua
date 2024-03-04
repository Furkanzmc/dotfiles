if vim.b.did_ftp == true then
    return
end

vim.opt_local.keywordprg = ":ZkHover -preview"
vim.opt_local.signcolumn = "no"
vim.opt_local.showbreak = "                       "
vim.opt_local.winbar = ""
vim.opt_local.cursorline = true
vim.opt_local.cursorlineopt = "both"
