if vim.b.did_ftp == true then
    return
end

vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = "no"

vim.opt_local.statusline = ""
vim.o.laststatus = 0
vim.opt_local.winbar = ""
