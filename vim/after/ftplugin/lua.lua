if vim.b.did_ftp == true then return end

vim.bo.suffixesadd = ".lua"
vim.wo.foldmethod = "expr"
vim.wo.colorcolumn = "81,101"
vim.bo.textwidth = 100
