if vim.b.vimrc_did_qmake == true then return end

vim.bo.commentstring = "#\\ %s"
vim.wo.foldmethod = "indent"

vim.b.vimrc_did_qmake = true
