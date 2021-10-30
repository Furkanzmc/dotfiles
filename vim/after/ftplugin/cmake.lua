if vim.b.did_ftp == true then
	return
end

local opt_local = vim.opt_local
local b = vim.b

opt_local.textwidth = 100
opt_local.cursorline = true
opt_local.colorcolumn = "101"
opt_local.signcolumn = "number"

b.vimrc_null_ls_lsp_signs_enabled = 1
b.vimrc_null_ls_lsp_location_list_enabled = 1
