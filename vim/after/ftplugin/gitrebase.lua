if vim.b.did_ftp == true then
    return
end

vim.opt_local.colorcolumn = ""
vim.opt_local.number = true
vim.opt_local.relativenumber = true
vim.opt_local.cursorline = true
vim.opt_local.cursorlineopt = "both"
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"
vim.opt_local.winbar = ""
