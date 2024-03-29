if vim.b.did_ftp == true then
    return
end

vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.colorcolumn = ""
vim.opt_local.breakindentopt = "shift:1"
vim.opt_local.signcolumn = "no"
vim.opt_local.wrap = true
vim.opt_local.cursorline = true
vim.opt_local.cursorlineopt = "both"
vim.opt_local.cursorcolumn = false
vim.opt_local.winbar = ""

local bufnr = vim.fn.bufnr()

if vim.o.loadplugins == true then
    require("options").set_local("highlight_trailing_whitespace", "false", bufnr)
end

vim.keymap.set(
    "n",
    "p",
    [[:lua require"vimrc.quickfix".preview_file_on_line(vim.fn.line('.'), vim.fn.getloclist(0, { filewinid = 0 }).filewinid > 0, false)<CR>]],
    { silent = true, buffer = bufnr }
)
vim.keymap.set(
    "n",
    "P",
    [[:lua require"vimrc.quickfix".preview_file_on_line(vim.fn.line('.'), vim.fn.getloclist(0, { filewinid = 0 }).filewinid > 0, true)<CR>]],
    { silent = true, buffer = bufnr }
)

vim.keymap.set(
    "n",
    "dd",
    [[:lua require"vimrc.quickfix".remove_qf_entries(vim.api.nvim_get_current_buf(), vim.fn.line("."), vim.fn.line("."))<CR>]],
    { silent = true, buffer = bufnr }
)

vim.keymap.set(
    "v",
    "d",
    [[:lua require"vimrc.quickfix".remove_qf_entries(vim.api.nvim_get_current_buf(), vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2])<CR>]],
    { silent = true, buffer = bufnr }
)

vim.api.nvim_create_autocmd({ "BufLeave" }, {
    buffer = bufnr,
    callback = function(opts)
        local bufnr = opts.buf
        local tabpagenr = vim.fn.tabpagenr()
        local winheight = vim.fn.winheight(vim.fn.winnr())
        local data = vim.g.vimrc_quickfix_size_cache or {}

        data[tostring(tabpagenr)] = winheight
        vim.g.vimrc_quickfix_size_cache = data
    end,
})
