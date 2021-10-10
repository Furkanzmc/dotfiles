local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local g = vim.g
local b = vim.b
local bo = vim.bo
local utils = require "vimrc.utils"
local log = require "futils.log"
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

    local status, path_backup = pcall(api.nvim_buf_get_option, fn.bufnr(),
                                      "path")

    if status == false then path_backup = "" end

    vim.opt_local.path:append(fn.expand("%:h"))

    local found = false
    for _, suffix in ipairs(suffixes) do
        local found_file = fn.findfile(filename .. suffix)
        if found_file ~= "" then
            found = true
            cmd("edit " .. found_file)
            break
        end
    end

    bo.path = path_backup

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
--       build_dir="~/random/MuseScore/build.debug/",
--       test_folder="~/random/MuseScore/build.debug/test/Debug",
--       test_cwd="~/random/MuseScore/build.debug/test"
--       generator="Ninja"
--   })
function M.setup_cmake(opts)
    if vim.o.loadplugins == false then return end

    require"vimrc.dap".init()

    opts.env = opts.env or {}

    assert(opts.env, "env is required.")
    assert(opts.name, "name is required.")
    assert(opts.program, "program is required.")
    assert(opts.cwd, "cwd is required.")
    assert(opts.project_path, "project_path is required.")
    assert(opts.build_dir, "build_dir is required.")

    opts.test_folder = opts.test_folder or ""
    opts.test_cwd = opts.test_cwd or ""

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
        require"firvish.job_control".start_job({
            cmd = {"cmake", "--build", ".", "--parallel"},
            filetype = "log",
            title = "Build",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.build_dir
        })
    end

    functions.run_tests = function(output_qf)
        require"firvish.job_control".start_job({
            cmd = {"ctest", "--output-on-failure", "-C", opts.test_folder},
            filetype = "log",
            title = "Tests",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.test_cwd
        })
    end

    local configure_opts = {"cmake", "-DCMAKE_BUILD_TYPE=Debug", opts.project_path}
    if opts.generator ~= nil then
        table.insert(configure_opts, "-G")
        table.insert(configure_opts, opts.generator)
    end

    functions.run_cmake = function(output_qf, cmake_options)
        local cmd = configure_opts
        if cmake_options ~= nil then table.extend(cmd, cmake_options) end

        require"firvish.job_control".start_job({
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

        require"firvish.job_control".start_job({
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
    cmd [[command! -bang RunTests :lua _G.cmake_functions.run_tests("<bang>" ~= "!")]]
    cmd(
        "command! UpdateTags :execute 'FRun! pwsh -NoLogo -NoProfile -NonInteractive -WorkingDirectory " ..
            opts.project_path .. " -Command Generate-Tags c++'")
end

return M
