local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local utils = require "vimrc.utils"
local M = {}

local function get_fd_args(cmd_line_args)
    local fd_args = {}

    is_arg = false
    table.for_each(cmd_line_args, function(val, key)
        if is_arg then
            table.insert(fd_args, val)
            is_arg = false
        elseif string.starts_with(val, "-") then
            table.insert(fd_args, val)
            is_arg = true
        end
    end)

    return fd_args
end

function M.open_files(args, use_split)
    if #args == 0 then
        return
    end

    local command = {}
    table.extend(command, fn.split(args, " "))
    fd_args = get_fd_args(command)

    command = table.filter(command, function(val, k, t) return table.index_of(fd_args, val) == -1 end)
    command = table.filter(command, function(val, k, t) return #val > 0 end)
    if use_split == true then
        command = table.map(command, function(val, k, t)
            if k == 1 then
                return "edit " .. val
            end

            return "split " .. val
        end)
    else
        command = table.map(command, function(val, k, t) return "edit " .. val end)
    end

    table.for_each(command, function(val, k) cmd(val) end)
end

function M.complete(arg_lead, cmd_line, cursor_pos)
    local search_paths = {}
    table.extend(search_paths, fn.split(vim.o.path, ","))

    local ok, local_paths = pcall(vim.api.nvim_buf_get_option, 0, "path")
    if ok then
        table.extend(search_paths, fn.split(local_paths, ","))
    end

    search_paths = table.filter(search_paths, function(val, k, t) return fn.isdirectory(val) == 1 end)
    search_paths = table.uniq(search_paths)

    local args = {"fd"}
    cmd_line = string.gsub(cmd_line, "^Find!", "")
    cmd_line = string.gsub(cmd_line, "^Find", "")
    cmd_args = fn.split(cmd_line, " ")
    fd_args = get_fd_args(cmd_args)
    if #cmd_args == #fd_args then
        table.insert(cmd_args, ".")
    end

    table.extend(args, fd_args)
    table.insert(args, cmd_args[#cmd_args])
    table.extend(args, search_paths)

    local result = fn.systemlist(args)
    return table.map(result, function(val, k, t) return fn.fnamemodify(val, ":~:.") end)
end

return M
