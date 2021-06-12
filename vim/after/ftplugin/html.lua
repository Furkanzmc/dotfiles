vim.wo.colorcolumn = "120"
vim.bo.suffixesadd = ".html"

require"vimrc.options".set_local("indentsize", 2, vim.api.nvim_get_current_buf())

vim.b.did_html_ext = true
