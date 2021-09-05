if vim.b.did_ftp == true then return end

if vim.g.vimrc_rust_loaded_plugins == nil and vim.o.loadplugins then
    vim.cmd [[packadd tagbar]]
    vim.cmd [[packadd rust.vim]]
    vim.g.vimrc_rust_loaded_plugins = true
end

vim.wo.signcolumn = "yes"
vim.bo.suffixesadd = ".rs"

if vim.fn.executable("rustfmt") == 1 then vim.bo.formatprg = "rustfmt" end

if vim.fn.executable("rustup") == 1 then vim.bo.keywordprg = "rustup\\ doc" end

vim.b.vimrc_rust_analyzer_lsp_signs_enabled = 1
vim.b.vimrc_rust_analyzer_lsp_location_list_enabled = 1
vim.b.vimrc_efm_lsp_signs_enabled = 1
vim.b.vimrc_efm_lsp_location_list_enabled = 1
