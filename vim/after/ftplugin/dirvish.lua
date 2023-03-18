if vim.b.did_ftp == true then
    return
end

local bufnr = vim.api.nvim_get_current_buf()

vim.opt_local.cursorline = true
vim.opt_local.cursorcolumn = false
vim.opt_local.signcolumn = "no"
vim.opt_local.winbar = ""

if vim.g.vimrc_dirvish_virtual_text_prefix == nil then
    vim.g.vimrc_dirvish_virtual_text_prefix = "> "
end

if vim.fn.executable("qlmanage") == 1 then
    vim.keymap.set(
        "n",
        "<leader>l",
        ':call jobstart(["qlmanage", "-p", getline(".")])<CR>',
        { silent = true, buffer = bufnr }
    )
end

vim.keymap.set(
    "n",
    "S",
    ':lua require"vimrc.dirvish".show_status(1, vim.fn.line("$"))<CR>',
    { silent = true, buffer = bufnr }
)
vim.keymap.set(
    "v",
    "S",
    ':lua require"vimrc.dirvish".show_status(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
    { silent = true, buffer = bufnr }
)
vim.keymap.set("n", "C", ':lua require"vimrc.dirvish".toggle_conceal()<CR>', {
    silent = true,
    buffer = bufnr,
})

vim.keymap.set(
    "n",
    "F",
    ":noautocmd Sort -folder-first | setlocal conceallevel=2<CR>",
    { silent = true, buffer = bufnr }
)
vim.keymap.set(
    "v",
    "F",
    ":noautocmd Sort -folder-first | setlocal conceallevel=2<CR>",
    { silent = true, buffer = bufnr }
)

require("vimrc.dirvish").init()
