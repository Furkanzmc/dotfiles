vim.cmd([[augroup vimrc_filetypes]])
vim.cmd([[au!]])
vim.cmd([[autocmd TermOpen * setlocal filetype=terminal]])
vim.cmd([[augroup END]])

vim.filetype.add({
    extension = {
        todo = "todo",
        http = "http",
        mt = "tags",
        mdc = "markdown",
    },
    filename = {
        ["todo.txt"] = "todo",
        ["CMakeLists.txt"] = "cmake",
        [".gitignore"] = "gitignore",
        [".gitignore_global"] = "gitignore",
    },
    pattern = {
        ["term:.*"] = "terminal",
    },
})
