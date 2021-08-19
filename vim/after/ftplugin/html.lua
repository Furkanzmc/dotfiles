if vim.b.vimrc_did_html == true then return end

local bufnr = vim.api.nvim_get_current_buf()

vim.wo.colorcolumn = "120"
vim.bo.suffixesadd = ".html"

require"vimrc.options".set_local("indentsize", 2, bufnr)

vim.b.did_html_ext = true

vim.b.vimrc_did_html = true
