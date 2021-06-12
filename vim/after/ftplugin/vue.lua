vim.bo.commentstring = "//\\ %s"
vim.wo.colorcolumn = 120

require"vimrc.options".set_local("indentsize", 2, vim.api.nvim_get_current_buf())
