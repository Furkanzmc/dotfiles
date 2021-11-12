if vim.b.did_ftp == true then
    return
end

vim.opt_local.foldmethod = "indent"
vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false
vim.opt_local.colorcolumn = ""
vim.opt_local.signcolumn = "yes"

vim.b.vimrc_null_ls_lsp_signs_enabled = 1
vim.b.vimrc_null_ls_lsp_virtual_text_enabled = 1
