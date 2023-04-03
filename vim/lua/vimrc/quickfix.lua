local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api

local s_auto_preview_enabled = false
local s_augroup_vimrc_init = -1
local s_autocmd_id = -1

local M = {}

local function delete_event()
    api.nvim_del_autocmd(s_autocmd_id)
    api.nvim_del_augroup_by_id(s_augroup_vimrc_init)
    s_augroup_vimrc_init = -1
    s_autocmd_id = -1
end

local function create_event(bufnr)
    s_augroup_vimrc_init = api.nvim_create_augroup("vimrc_init", { clear = true })
    s_autocmd_id = api.nvim_create_autocmd({ "CursorMoved", "WinClosed", "BufLeave" }, {
        group = s_augroup_vimrc_init,
        buffer = bufnr,
        callback = function(opts)
            if opts.event == "CursorMoved" then
                M.preview_file_on_line(
                    fn.line("."),
                    fn.getloclist(0, { filewinid = 0 }).filewinid > 0
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

function M.remove_qf_entries(bufnr, start_line, end_line)
    local position = fn.getpos(".")
    local qf_list = fn.getqflist()
    local qf_winid = fn.bufwinid(bufnr)
    local prev_title = vim.fn.getqflist({ title = qf_winid }).title
    local new_qf_list = {}

    for index, entry in ipairs(qf_list) do
        if index < start_line or index > end_line then
            table.insert(new_qf_list, entry)
        end
    end

    fn.setqflist({}, " ", { title = prev_title, items = new_qf_list })
    fn.setpos(".", position)
end

return M
