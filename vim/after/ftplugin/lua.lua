if vim.b.did_ftp == true then
    return
end

vim.bo.suffixesadd = ".lua"
vim.wo.foldmethod = "expr"
vim.bo.textwidth = 100
vim.wo.signcolumn = "yes"
vim.opt_local.cursorcolumn = false

vim.b.vimrc_sumneko_lua_lsp_signs_enabled = 1
