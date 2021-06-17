vim.wo.foldmethod = "indent"
vim.wo.cursorline = true
vim.bo.suffixesadd = ".json"

if vim.fn.executable("jq") == 1 then vim.bo.formatprg = "jq" end

vim.b.vimrc_jsonls_lsp_signs_enabled = 1
vim.b.vimrc_jsonls_lsp_virtual_text_enabled = 1
vim.b.vimrc_jsonls_lsp_location_list_enabled = 1
