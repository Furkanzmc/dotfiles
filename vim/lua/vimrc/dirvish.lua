local vim = vim
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local wo = vim.wo
local M = {}

function M.toggle_conceal()
    if wo.conceallevel == 0 then
        wo.conceallevel = 2
    else
        wo.conceallevel = 0
    end
end

local function get_info(path)
    local lines = {}
    local size = fn.getfsize(path)

    local size_text = ""
    if size > -1 then
        local last_modified =
            fn.strftime('%Y-%m-%d.%H:%M:%S', fn.getftime(path))
        if size < 1000000 then
            size_text = string.format('%.2f', size / 1000.0) .. 'K'
        else
            size_text = string.format('%.2f', size / 1000000.0) .. 'MB'
        end

        table.extend(lines, {
            {last_modified, "String"}, {" | ", "Operator"},
            {size_text, "Number"}
        })
    end

    return lines
end

function M.show_status(line1, line2)
    if b.vimrc_dirvish_initial_dir == nil then
        b.vimrc_dirvish_initial_dir = fn.expand("%")
        b.vimrc_dirvish_namespace = api.nvim_create_namespace(
                                        b.vimrc_dirvish_initial_dir)
        b.vimrc_dirvish_current_line = -1
    end

    local bufnr = api.nvim_get_current_buf()

    if line1 == line2 and b.vimrc_dirvish_current_line ~= line1 then
        api.nvim_buf_clear_namespace(bufnr, b.vimrc_dirvish_namespace, bufnr, -1)
    elseif line1 == line2 and b.vimrc_dirvish_current_line == line1 then
        return
    end

    local lines = api.nvim_buf_get_lines(bufnr, line1 - 1, line2, true)
    local linenr = line1 - 1

    for _, line in pairs(lines) do
        local status_lines = {}

        table.insert(status_lines,
                     {g.vimrc_dirvish_virtual_text_prefix, "SpecialKey"})
        table.extend(status_lines, get_info(fn.fnamemodify(line, ":.")))
        if #status_lines > 1 then
            api.nvim_buf_set_virtual_text(bufnr, b.vimrc_dirvish_namespace,
                                          linenr, status_lines, {})
        end

        linenr = linenr + 1
    end

    if line1 == line2 then b.vimrc_dirvish_current_line = line1 end
end

function M.clear_status(all)
    if b.vimrc_dirvish_namespace == nil then return end

    if all or fn.line(".") ~= b.vimrc_dirvish_current_line then
        api.nvim_buf_clear_namespace(0, b.vimrc_dirvish_namespace, 0, -1)
    end
end

function M.init()
    cmd [[augroup dirvish_virtual_text]]
    cmd [[au! * <buffer>]]
    cmd [[autocmd CursorHold,BufEnter <buffer> lua require"vimrc.dirvish".show_status(vim.fn.line("."), vim.fn.line("."))]]
    cmd [[autocmd CursorMoved <buffer> lua require"vimrc.dirvish".clear_status(false)]]
    cmd [[autocmd BufLeave <buffer> lua require"vimrc.dirvish".clear_status(true)]]
    cmd [[augroup END]]
end

return M
