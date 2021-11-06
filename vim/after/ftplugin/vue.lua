if vim.b.did_ftp == true then
    return
end

local bufnr = vim.api.nvim_get_current_buf()

vim.bo.commentstring = "//\\ %s"
vim.wo.colorcolumn = 120

require("options").set_local("indentsize", 2, bufnr)
