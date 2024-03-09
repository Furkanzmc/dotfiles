local vim = vim
local fn = vim.fn
local api = vim.api
local bo = vim.bo
local log = require("vimrc.log")
local M = {}

local function setup_cmake_commands(opts)
    local functions = {}
    functions.build_project = function(output_qf)
        require("firvish.job_control").start_job({
            cmd = { "cmake", "--build", opts.build_dir, "--parallel" },
            filetype = "log",
            title = "Build",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.project_path,
        })
    end

    functions.run_tests = function(output_qf)
        require("firvish.job_control").start_job({
            cmd = { "ctest", "--output-on-failure" },
            filetype = "log",
            title = "Tests",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.test_cwd,
        })
    end

    local configure_opts = { "cmake", "-DCMAKE_BUILD_TYPE=Debug" }
    table.extend(configure_opts, opts.cmake_args)
    table.insert(configure_opts, opts.project_path)
    if opts.generator ~= nil then
        table.insert(configure_opts, "-G")
        table.insert(configure_opts, opts.generator)
    end

    functions.run_cmake = function(output_qf, cmake_options)
        local cmd = configure_opts
        if cmake_options ~= nil then
            table.extend(cmd, cmake_options)
        end

        require("firvish.job_control").start_job({
            cmd = cmd,
            filetype = "log",
            title = "CMake",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.build_dir,
        })
    end

    functions.run_project = function(output_qf, args)
        local cmd = { opts.program }
        if args ~= nil then
            table.extend(cmd, args)
        end

        require("firvish.job_control").start_job({
            cmd = cmd,
            filetype = "log",
            title = "Run",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.cwd,
        })
    end

    _G.cmake_functions = functions

    vim.api.nvim_command(
        [[command! -bang CMake :lua _G.cmake_functions.run_cmake("<bang>" ~= "!")]]
    )
    vim.api.nvim_command(
        [[command! -bang Run :lua _G.cmake_functions.run_project("<bang>" ~= "!")]]
    )
    vim.api.nvim_command(
        [[command! -bang Build :lua _G.cmake_functions.build_project("<bang>" ~= "!")]]
    )
    vim.api.nvim_command(
        [[command! -bang RunTests :lua _G.cmake_functions.run_tests("<bang>" ~= "!")]]
    )
    vim.api.nvim_command(
        "command! UpdateTags :execute 'FRun! pwsh -NoLogo -NoProfile -NonInteractive -WorkingDirectory "
            .. opts.project_path
            .. " -Command Generate-Tags c++'"
    )
end

function M.swap_source_header()
    local bufnr = fn.bufnr()
    local suffixes = string.split(api.nvim_buf_get_option(bufnr, "suffixesadd"), ",")

    local filename = fn.expand("%:t")
    for index, suffix in ipairs(suffixes) do
        local tmp = string.gsub(filename, suffix .. "$", "")
        if filename ~= tmp then
            filename = tmp
            table.remove(suffixes, index)
        end
    end

    local status, path_backup = pcall(api.nvim_buf_get_option, bufnr, "path")

    if status == false then
        path_backup = ""
    end

    vim.opt_local.path:append(fn.expand("%:h"))

    local found = false
    for _, suffix in ipairs(suffixes) do
        local found_file = fn.findfile(filename .. suffix)
        if found_file ~= "" then
            found = true
            vim.api.nvim_command("edit " .. found_file)
            break
        end
    end

    bo.path = path_backup

    if found == false then
        log.error("cpp", "Cannot swap source/header for " .. fn.expand("%:t"))
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
--       test_cwd="~/random/MuseScore/build.debug/test"
--       generator="Ninja"
--       cmake_args={},
--       no_cmake=false
--   })
function M.setup_cmake(opts)
    if vim.o.loadplugins == false then
        return
    end

    opts.test_cwd = opts.test_cwd or ""
    opts.env = opts.env or {}
    opts.run_in_terminal = opts.run_in_terminal or false
    opts.cmake_args = opts.cmake_args or {}
    if opts.no_cmake == nil then
        opts.no_cmake = false
    end

    assert(opts.env, "env is required.")
    assert(opts.name, "name is required.")
    assert(opts.program, "program is required.")
    assert(opts.cwd, "cwd is required.")
    assert(opts.project_path, "project_path is required.")
    assert(opts.build_dir, "build_dir is required.")

    require("vimrc.dap").init({
        language = "cpp",
        name = opts.name,
        program = opts.program,
        cwd = opts.cwd,
        env = opts.env,
        run_in_terminal = opts.run_in_terminal,
    })

    require("dap").configurations.cpp = {
        {
            type = "cpp",
            request = "launch",
            name = opts.name,
            program = opts.program,
            symbolSearchPath = opts.cwd,
            cwd = opts.cwd,
            debuggerRoot = opts.cwd,
            env = opts.env,
            runInTerminal = opts.run_in_terminal,
        },
    }

    if opts.no_cmake == false then
        setup_cmake_commands(opts)
    end
end

return M
