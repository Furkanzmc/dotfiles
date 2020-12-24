local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local M = {}

function M.url_text_object()
    local url_regex =
        '\\(https\\|http\\)\\?:\\/\\/\\(\\w\\+\\(:\\w\\+\\)\\?@\\)\\?\\([A-Za-z][-_0-9A-Za-z]*\\.\\)\\{1,}\\(\\w\\{2,}\\.\\?\\)\\{1,}\\(:[0-9]\\{1,5}\\)\\?\\S*'
    local linenr = fn.line('.')

    if fn.search(url_regex, 'ceW', linenr) ~= 0 then
        cmd [[normal v]]
        fn.search(url_regex, 'bcW', linenr)
    end
end

function M.number_text_object()
    local url_regex = '[0-9]\\+'
    local linenr = fn.line('.')

    if fn.search(url_regex, 'ceW', linenr) ~= 0 then
        cmd [[normal v]]
        fn.search(url_regex, 'bcW', linenr)
    end
end

return M
