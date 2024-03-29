if vim.b.did_ftp == true then
    return
end

local bufnr = vim.api.nvim_get_current_buf()

vim.bo.commentstring = "//\\ %s"
vim.opt_local.textwidth = 120
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"

require("options").set_local("indentsize", 2, bufnr)
