if vim.b.did_ftp == true then
	return
end

vim.bo.commentstring = "#\\ %s"
vim.bo.suffixesadd = ".qml"
