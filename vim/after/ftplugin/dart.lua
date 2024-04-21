if vim.b.did_ftp == true then
    return
end

vim.opt_local.cindent = false
vim.opt_local.suffixesadd = ".dart"
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "yes"
vim.opt_local.textwidth = 100
vim.opt_local.formatprg = "dart format --set-exit-if-changed"
vim.opt_local.makeprg = "dart $*"
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
