if vim.b.vimrc_did_lua == true then return end

vim.bo.suffixesadd = ".lua"
vim.wo.foldmethod = "expr"
vim.wo.colorcolumn = "81,101"
vim.bo.textwidth = 100

vim.b.did_lua_ext = true

vim.b.vimrc_did_lua = true
