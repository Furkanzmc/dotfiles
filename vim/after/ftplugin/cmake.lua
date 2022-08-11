if vim.b.did_ftp == true then
    return
end

local opt_local = vim.opt_local
local b = vim.b

opt_local.textwidth = 100
opt_local.cursorline = true
opt_local.colorcolumn = "101"
opt_local.signcolumn = "yes"
opt_local.cursorline = false
opt_local.cursorcolumn = false

b.vimrc_null_ls_lsp_signs_enabled = 1
