if vim.b.vimrc_did_markdown == true then return end

if vim.o.loadplugins and vim.g.vimrc_markdown_loaded_plugins == nil then
    vim.cmd [[packadd vim-markdown-folding]]
    vim.cmd [[packadd SyntaxRange]]
    vim.g.vimrc_markdown_loaded_plugins = true
end

vim.opt_local.spell = true
vim.opt_local.colorcolumn = "100"
vim.opt_local.foldmethod = "expr"
vim.opt_local.conceallevel = 2
vim.opt_local.textwidth = 99
vim.opt_local.cursorline = true

vim.cmd [[command -buffer -range RunQML :call qml#run()]]

vim.b.vimrc_did_markdown = true
