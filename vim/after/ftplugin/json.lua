if vim.b.did_ftp == true then
    return
end

vim.opt_local.foldmethod = "indent"
vim.opt_local.cursorline = true
vim.opt_local.cursorlineopt = "both"
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "yes"
vim.bo.suffixesadd = ".json"

if vim.fn.executable("jq") == 1 then
    vim.bo.formatprg = "jq"
end

vim.b.vimrc_null_ls_lsp_signs_enabled = 1
vim.b.vimrc_null_ls_lsp_virtual_text_enabled = 1
