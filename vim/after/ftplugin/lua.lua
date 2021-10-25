if vim.b.did_ftp == true then return end

vim.bo.suffixesadd = ".lua"
vim.wo.foldmethod = "expr"
vim.wo.colorcolumn = "81,101"
vim.bo.textwidth = 100
vim.wo.signcolumn = "number"

vim.b.vimrc_sumneko_lua_lsp_signs_enabled = 1
vim.b.vimrc_sumneko_lua_lsp_location_list_enabled = 1
