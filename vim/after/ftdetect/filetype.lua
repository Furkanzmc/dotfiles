vim.cmd([[augroup vimrc_filetypes]])
vim.cmd([[au!]])
vim.cmd([[autocmd TermOpen * setlocal filetype=terminal]])
vim.cmd([[augroup END]])

vim.filetype.add({
    extension = {
        todo = "todo",
        http = "http",
        mt = "tags",
        qml = "qml",
        qmlproject = "qmldir",
        qmltypes = "qml",
    },
    filename = {
        ["todo.txt"] = "todo",
        ["CMakeLists.txt"] = "cmake",
        ["qmldir"] = "qmldir",
        [".gitignore"] = "gitignore",
        [".gitignore_global"] = "gitignore",
    },
    pattern = {
        ["term:.*"] = "terminal",
    },
})
