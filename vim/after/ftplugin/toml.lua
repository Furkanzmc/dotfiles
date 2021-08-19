if vim.b.vimrc_did_toml == true then return end

vim.bo.commentstring = "#\\ %s"

vim.b.vimrc_did_toml = true
