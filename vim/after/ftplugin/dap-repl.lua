if vim.b.did_ftp == true then
    return
end

local bufnr = vim.api.nvim_get_current_buf()
vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false
vim.opt_local.colorcolumn = ""
vim.opt_local.signcolumn = "no"
vim.opt_local.winbar = ""

vim.keymap.set("n", "]dp", ":call search('^dap>', 'W')<CR>", { silent = true, buffer = bufnr })
vim.keymap.set("n", "[dp", "call search('^dap>', 'Wb')<CR>", { silent = true, buffer = bufnr })
