local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local utils = require "vimrc.utils"
local log = require "vimrc.log"
local M = {}

function M.swap_source_header()
    local suffixes = string.split(bo.suffixesadd, ",")

    local filename = fn.expand('%:t')
    for index, suffix in ipairs(suffixes) do
        local tmp = string.gsub(filename, suffix .. "$", "")
        if filename ~= tmp then
            filename = tmp
            table.remove(suffixes, index)
        end
    end

    cmd("execute 'setlocal path+=' . expand('%:h')")

    local found = false
    for _, suffix in ipairs(suffixes) do
        local found_file = fn.findfile(filename .. suffix)
        if found_file ~= "" then
            found = true
            cmd("edit " .. found_file)
            break
        end
    end

    cmd("execute 'setlocal path-=' . expand('%:h')")

    if found == false then
        log.error("cpp", "Cannot swap source/header for " .. fn.expand('%:t'))
    end
end

-- Sample call:
--   require"vimrc.cpp".setup_cmake({
--       env={},
--       name="MuseScore",
--       program="~/random/MuseScore/build.debug/src/main/mscore.app/Contents/MacOS/mscore",
--       cwd="~/random/MuseScore/build.debug/src/main/mscore.app/Contents/MacOS/",
--       project_path="~/random/MuseScore/",
--       build_dir="~/random/MuseScore/build.debug/"
--   })
function M.setup_cmake(opts)
    if vim.o.loadplugins == false then return end

    cmd [[packadd nvim-dap]]

    require"vimrc.dap".init()

    opts.env = opts.env or {}

    assert(opts.env, "env is required.")
    assert(opts.name, "name is required.")
    assert(opts.program, "program is required.")
    assert(opts.cwd, "cwd is required.")
    assert(opts.project_path, "project_path is required.")
    assert(opts.build_dir, "build_dir is required.")

    require"dap".configurations.cpp = {
        {
            type = "cpp",
            request = "launch",
            name = opts.name,
            program = opts.program,
            symbolSearchPath = opts.cwd,
            cwd = opts.cwd,
            debuggerRoot = opts.cwd,
            env = opts.env
        }
    }

    local functions = {}
    functions.build_project = function(output_qf)
        require"firvish.job_control".start_job(
            {
                cmd = {"make", "-j2"},
                filetype = "log",
                title = "Build",
                listed = true,
                output_qf = output_qf,
                is_background_job = true,
                cwd = opts.build_dir
            })
    end

    functions.run_cmake = function(output_qf, cmake_options)
        local cmd = {"cmake", opts.project_path}
        if cmake_options ~= nil then table.extend(cmd, cmake_options) end

        require"firvish.job_control".start_job(
            {
                cmd = cmd,
                filetype = "log",
                title = "CMake",
                listed = true,
                output_qf = output_qf,
                is_background_job = true,
                cwd = opts.build_dir
            })
    end

    functions.run_project = function(output_qf, args)
        local cmd = {opts.program}
        if args ~= nil then table.extend(cmd, args) end

        require"firvish.job_control".start_job(
            {
                cmd = cmd,
                filetype = "log",
                title = "Run",
                listed = true,
                output_qf = output_qf,
                is_background_job = true,
                cwd = opts.cwd
            })
    end

    _G.cmake_functions = functions

    cmd [[command! -bang CMake :lua _G.cmake_functions.run_cmake("<bang>" ~= "!")]]
    cmd [[command! -bang Run :lua _G.cmake_functions.run_project("<bang>" ~= "!")]]
    cmd [[command! -bang Build :lua _G.cmake_functions.build_project("<bang>" ~= "!")]]
    cmd(
        "command! UpdateTags :execute 'FRun! pwsh -NoLogo -NoProfile -NonInteractive -WorkingDirectory " ..
            opts.project_path .. " -Command Generate-Tags c++'")
end

return M
