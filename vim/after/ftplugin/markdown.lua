if vim.b.did_markdown_ext ~= true and vim.o.loadplugins == 1 then
    vim.cmd [[packadd vim-markdown-folding]]
    vim.cmd [[packadd SyntaxRange]]
end

vim.bo.spell = true
vim.wo.colorcolumn = "81,101"
vim.wo.foldmethod = "expr"
vim.wo.conceallevel = 2
vim.bo.textwidth = 100

if vim.b.did_markdown_ext ~= true then
    vim.cmd [[command -buffer -range RunQML :call qml#run()]]
end

vim.b.did_markdown_ext = true
