if vim.b.did_markdown_ext ~= true and vim.o.loadplugins then
    vim.cmd [[packadd vim-markdown-folding]]
    vim.cmd [[packadd SyntaxRange]]
end

vim.wo.spell = true
vim.wo.colorcolumn = "100"
vim.wo.foldmethod = "expr"
vim.wo.conceallevel = 2
vim.bo.textwidth = 99
vim.wo.cursorline = true

if vim.b.did_markdown_ext ~= true then
    vim.cmd [[command -buffer -range RunQML :call qml#run()]]
end

vim.b.did_markdown_ext = true
