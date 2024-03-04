if vim.b.did_ftp == true then
    return
end

local bufnr = vim.api.nvim_get_current_buf()

vim.opt_local.textwidth = 120
vim.bo.suffixesadd = ".html"
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"

require("options").set_local("indentsize", 2, bufnr)

vim.b.did_html_ext = true
