if vim.b.did_markdown_ext ~= true and vim.o.loadplugins then
    vim.cmd [[packadd vim-markdown-folding]]
    vim.cmd [[packadd SyntaxRange]]
end

vim.opt_local.spell = true
vim.opt_local.colorcolumn = "100"
vim.opt_local.foldmethod = "expr"
vim.opt_local.conceallevel = 2
vim.opt_local.textwidth = 99
vim.opt_local.cursorline = true

if vim.b.did_markdown_ext ~= true then
    vim.cmd [[command -buffer -range RunQML :call qml#run()]]
end

vim.b.did_markdown_ext = true
