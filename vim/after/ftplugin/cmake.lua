if vim.b.did_ftp == true then
    return
end

local opt_local = vim.opt_local
local b = vim.b

opt_local.textwidth = 100
opt_local.signcolumn = "yes"
opt_local.cursorcolumn = false
opt_local.formatprg = "cmake-format -"

b.vimrc_null_ls_lsp_signs_enabled = 1
