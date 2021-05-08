-- TODO
-- [ ] Add support for more types.
-- [ ] Add support for window and buffer local options.
-- [ ] Add support for options.indentsize=4 syntax for init.lua
local vim = vim
local cmd = vim.cmd
local log = require "vimrc.log"
local utils = require "vimrc.utils"
local typing = require "vimrc.typing"
local M = {}

local s_registered_options = {
    clstrailingwhitespace = {
        default = true,
        type_info = "bool",
        source = "buffers",
        buffer_local = true
    },
    clstrailingspacelimit = {
        default = 0,
        type_info = "int",
        source = "buffers",
        buffer_local = true,
        description = "If the number of trailing white spaces below this number, they will be cleared automatically. Otherwise you will be prompted for each one."
    },
    trailingwhitespacehighlight = {
        default = true,
        type_info = "bool",
        source = "buffers",
        buffer_local = true
    },
    indentsize = {
        default = 4,
        type_info = "int",
        source = "buffers",
        buffer_local = true
    },
    shell = {
        default = "pwsh",
        type_info = "string",
        source = "vimrc",
        global = true
    },
    scratchpad = {
        default = false,
        type_info = "bool",
        source = "vimrc",
        buffer_local = true
    }
}
local s_current_options = {}
local s_callbacks = {}

local function is_option_registered(name)
    return s_registered_options[name] ~= nil
end

local function get_option_info(name)
    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return nil
    end

    if s_registered_options[name] ~= nil then
        return s_registered_options[name]
    end
end

local function echo_options(bufnr)
    local processed = {}
    local message = "--"

    for key, info in pairs(s_current_options) do
        local val = nil
        local buffer_option = get_buffer_option(key, bufnr)

        if buffer_option ~= nil then
            val = buffer_option.value
        elseif bufnr == 0 and get_option_info(key).global == true then
            val = info.value
        end

        if val ~= nil then
            message = message .. "\n" .. string.rep(" ", 11) .. key .. "=" ..
                          tostring(val) .. ", " .. "[" ..
                          get_option_info(key).source .. "]"
            table.insert(processed, key)
        end
    end

    for key, info in pairs(s_registered_options) do
        local can_echo = false
        if table.index_of(processed, key) == -1 then
            if bufnr ~= 0 and info.buffer_local == true then
                can_echo = true
            elseif bufnr == 0 and info.global == true then
                can_echo = true
            end

            if can_echo then
                message =
                    message .. "\n" .. string.rep(" ", 11) .. key .. "=" ..
                        tostring(info.default) .. ", " .. "[" ..
                        get_option_info(key).source .. "]"
            end
        end
    end

    log.info("options", message)
end

local function execute_callbacks(option_name)
    if s_callbacks[option_name] == nil then return end

    for _, func in ipairs(s_callbacks[option_name]) do func() end
end

local function is_option_set(name)
    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return false
    end

    if s_current_options[name] == nil then return s_current_options[name] end

    if s_registered_options[name] == nil then
        return s_registered_options[name]
    end
end

function get_buffer_option(name, bufnr)
    local existing = s_current_options[name]
    if existing == nil then return end
    if bufnr == 0 then return nil end

    local buffers = existing.buffers
    for _, v in ipairs(buffers) do if v.bufnr == bufnr then return v end end

    return nil
end

local function set_option(name, value, bufnr)
    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return false
    end

    local existing = s_current_options[name]
    local buffer_option = get_buffer_option(name, bufnr)
    if existing == nil then
        if bufnr ~= 0 then
            s_current_options[name] = {
                value = nil,
                buffers = {{bufnr = bufnr, value = value}}
            }
        else
            s_current_options[name] = {value = value, buffers = {}}
        end

        execute_callbacks(name)
        cmd [[doautocmd User VimrcOptionSet]]
    elseif bufnr == 0 and existing.value ~= value then
        existing.value = value
        execute_callbacks(name)
        cmd [[doautocmd User VimrcOptionSet]]
    elseif bufnr > 0 and buffer_option ~= nil and buffer_option.value ~= value then
        buffer_option.value = value

        execute_callbacks(name)
        cmd [[doautocmd User VimrcOptionSet]]
    elseif bufnr > 0 and buffer_option == nil then
        table.insert(s_current_options[name].buffers,
                     {bufnr = bufnr, value = value})

        execute_callbacks(name)
        cmd [[doautocmd User VimrcOptionSet]]
    end
end

function M.get_option(name, bufnr)
    if bufnr == nil then bufnr = 0 end

    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return nil
    end

    local buffer_option = get_buffer_option(name, bufnr)
    if s_current_options[name] ~= nil and buffer_option ~= nil then
        return buffer_option.value
    elseif s_current_options[name] ~= nil and s_current_options[name].value ~=
        nil and buffer_option == nil then
        return s_current_options[name].value
    end

    assert(s_registered_options[name] ~= nil)
    return s_registered_options[name].default
end

function M.register_option(opts)
    if s_registered_options[opts.name] ~= nil then
        log.error("options", "This option is already registered: " .. opts.name)
        return
    end

    opts.buffer_local = opts.buffer_local or false
    opts.global = opts.global or true
    s_registered_options[opts.name] = {
        default = opts.default,
        type_info = opts.type_info,
        source = opts.source,
        buffer_local = opts.buffer_local,
        global = opts.global
    }
end

function M.set(option_str, bufnr)
    if bufnr == nil then bufnr = 0 end

    if option_str == "" then
        echo_options(bufnr)
        return
    end

    local cmps = string.split(option_str, "=")
    local name = cmps[1]

    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return nil
    end

    local value = nil
    if #cmps == 2 then value = cmps[2] end

    local option_info = get_option_info(name)
    if value == nil then
        if option_info.buffer_local == true then
            log.info(option_info.source .. "-buflocal",
                     name .. "=" .. tostring(M.get_option(name, bufnr)))
        else
            log.info(option_info.source,
                     name .. "=" .. tostring(M.get_option(name, bufnr)))
        end

        return
    end

    if option_info.buffer_local == true and bufnr == 0 then
        log.warning("options",
                    "This is only a local option. Use `:Setlocal` instead.")
        return nil
    end

    local converted_value = nil
    if option_info.type_info == "bool" then
        converted_value = typing.toboolean(value)
    elseif option_info.type_info == "int" then
        converted_value = tonumber(value)
    elseif option_info.type_info == "string" then
        converted_value = tostring(value)
    end

    if converted_value == nil then
        log.error("options", "Cannot convert `" .. value .. "` to " ..
                      option_info.type_info .. ".")
        return
    end

    set_option(name, converted_value, bufnr)
end

function M.list_options(arg_lead, buffer_local)
    local options = {}

    for key, info in pairs(s_registered_options) do
        if buffer_local == true and info.buffer_local == true then
            if string.match(key, "^" .. arg_lead) then
                table.insert(options, key)
            end
        elseif buffer_local ~= true and info.global == true then
            if string.match(key, "^" .. arg_lead) then
                table.insert(options, key)
            end
        end
    end

    return options
end

function M.register_callback(option_name, func)
    if s_callbacks[option_name] == nil then
        s_callbacks[option_name] = {func}
    else
        table.insert(s_callbacks[option_name], func)
    end
end

return M
