if vim.b.did_ftp == true then
    return
end

vim.cmd([[:runtime! ftplugin/cpp.lua]])

vim.opt_local.suffixesadd = ".c,.h"
