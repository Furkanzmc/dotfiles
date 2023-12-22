if vim.b.did_ftp == true then
    return
end

if vim.g.vimrc_zig_loaded_plugins == nil and vim.o.loadplugins then
    vim.cmd([[packadd zig.vim]])
    vim.g.vimrc_zig_loaded_plugins = true
end

vim.wo.signcolumn = "yes"
vim.opt_local.cursorline = false
vim.opt_local.cursorcolumn = false
vim.opt_local.textwidth = 90

if vim.fn.executable("zig") == 1 then
    vim.opt_local.formatprg = "zig fmt --stdin --check"
end

vim.b.vimrc_null_ls_lsp_signs_enabled = 1
