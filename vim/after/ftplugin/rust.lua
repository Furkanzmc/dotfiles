if vim.b.did_rust_ext ~= true and vim.o.loadplugins then
    vim.cmd [[packadd tagbar]]
    vim.cmd [[packadd rust.vim]]
end

vim.wo.signcolumn = "yes"
vim.bo.suffixesadd = ".rs"

if vim.fn.executable("rustfmt") == 1 then vim.bo.formatprg = "rustfmt" end

if vim.fn.executable("rustup") == 1 then vim.bo.keywordprg = "rustup\\ doc" end

vim.b.vimrc_rust_analyzer_lsp_signs_enabled = 1
vim.b.vimrc_rust_analyzer_lsp_location_list_enabled = 1
vim.b.vimrc_efm_lsp_signs_enabled = 1
vim.b.vimrc_efm_lsp_location_list_enabled = 1

vim.b.did_rust_ext = true
