if vim.b.vimrc_did_c == true then return end

vim.cmd [[:runtime! ftplugin/cpp.vim]]
vim.b.vimrc_did_c = true
