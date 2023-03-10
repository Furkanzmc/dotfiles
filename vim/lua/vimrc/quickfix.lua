local vim = vim
local fn = vim.fn
local cmd = vim.cmd

local s_auto_preview_enabled = false
local s_augroup_vimrc_init = -1
local s_autocmd_id = -1

local M = {}

local function delete_event()
    vim.api.nvim_del_autocmd(s_autocmd_id)
    vim.api.nvim_del_augroup_by_id(s_augroup_vimrc_init)
    s_augroup_vimrc_init = -1
    s_autocmd_id = -1
end

local function create_event(bufnr)
    s_augroup_vimrc_init = vim.api.nvim_create_augroup("vimrc_init", { clear = true })
    s_autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "WinClosed", "BufLeave" }, {
        group = s_augroup_vimrc_init,
        buffer = bufnr,
        callback = function(opts)
            if opts.event == "CursorMoved" then
                M.preview_file_on_line(
                    vim.fn.line("."),
                    vim.fn.getloclist(0, { filewinid = 0 }).filewinid > 0
                )
            else
                delete_event()
            end
        end,
    })
end

function M.preview_file_on_line(linenr, use_loclist, enable_auto_preview)
    if enable_auto_preview ~= nil then
        if enable_auto_preview == false and s_augroup_vimrc_init ~= -1 then
            delete_event()
        end

        s_auto_preview_enabled = enable_auto_preview
    end

    use_loclist = use_loclist or false
    local items = {}
    if use_loclist then
        items = fn.getloclist(0)
    else
        items = fn.getqflist()
    end

    local data = items[linenr]
    cmd("pedit +" .. data.lnum .. "," .. data.col .. " " .. fn.bufname(data.bufnr))
    cmd([[normal p]])
    cmd([[setlocal cursorline]])
    cmd("normal " .. data.lnum .. "G")
    cmd([[normal 0]])
    cmd("normal " .. data.col .. "l")
    cmd([[normal p]])

    if enable_auto_preview and s_augroup_vimrc_init == -1 then
        create_event(fn.bufnr())
    end
end

return M
