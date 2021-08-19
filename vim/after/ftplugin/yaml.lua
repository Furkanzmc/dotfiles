if vim.b.vimrc_did_yaml == true then return end

vim.opt_local.foldmethod = "indent"
vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = true
vim.opt_local.colorcolumn = ""
vim.opt_local.signcolumn = "yes"

vim.b.vimrc_efm_lsp_signs_enabled = 1
vim.b.vimrc_efm_lsp_location_list_enabled = 1

vim.b.vimrc_did_yaml = true
