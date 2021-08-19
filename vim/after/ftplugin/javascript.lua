if vim.b.vimrc_did_javascript == true then return end

vim.bo.cindent = false
vim.bo.suffixesadd = ".js,.jsx"

vim.b.vimrc_did_javascript = true
