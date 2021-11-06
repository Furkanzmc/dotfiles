if vim.b.did_ftp == true then
    return
end

local bufnr = vim.api.nvim_get_current_buf()

vim.wo.colorcolumn = "120"
vim.bo.suffixesadd = ".html"

require("options").set_local("indentsize", 2, bufnr)

vim.b.did_html_ext = true
