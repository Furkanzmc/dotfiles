if vim.b.did_ftp == true then
    return
end

local map = require("vimrc").map
local bufnr = vim.api.nvim_get_current_buf()
vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false
vim.opt_local.colorcolumn = ""
vim.opt_local.signcolumn = "no"

map("n", "]dp", ":call search('^dap>', 'W')<CR>", { silent = true, buffer = bufnr })
map("n", "[dp", "call search('^dap>', 'Wb')<CR>", { silent = true, buffer = bufnr })
