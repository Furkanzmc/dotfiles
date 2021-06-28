local abbreviate = require "vimrc.abbreviate"

abbreviate("today@", "<C-R>=strftime('%Y-%m-%d')<CR>",
           {buffer = true, silent = true})

vim.opt.showbreak = "           "
vim.opt_local.colorcolumn = ""
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.textwidth = 700
vim.opt_local.spell = true
