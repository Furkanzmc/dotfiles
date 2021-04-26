-- TODO
-- [ ] Add support for more types.
-- [ ] Add support for window and buffer local options.
-- [ ] Add support for options.indentsize=4 syntax for init.lua
local vim = vim
local cmd = vim.cmd
local log = require"vimrc.log"
local utils = require"vimrc.utils"
local typing = require"vimrc.typing"
local M = {}

local s_registered_options = {
    clstrailingwhitespace={default=true, type_info="bool", source="buffers"},
    indentsize={default=4, type_info="int", source="buffers"},
    shell={default="pwsh", type_info="string", source="vimrc"},
    scratchpad={default=false, type_info="bool", source="vimrc", buffer_only=true}
}
local s_current_options = {}
local s_callbacks = {}

local function is_option_registered(name)
    if s_current_options[name] == nil and s_registered_options[name] == nil then
        return false
    end

    return true
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

local function echo_options()
    local processed = {}
    local message = "--"

    for key,value in pairs(s_current_options) do
        table.insert(processed, key)
        message = message .. "\n" .. string.rep(" ", 11) .. key .. "=" .. tostring(value.value) .. ", " .. "[" .. get_option_info(key).source .. "]"
    end

    for key,value in pairs(s_registered_options) do
        if table.index_of(processed, key) == -1 then
            message = message .. "\n" .. string.rep(" ", 11) .. key .. "=" .. tostring(value.default) .. ", " .. "[" .. get_option_info(key).source .. "]"
        end
    end

    log.info("options", message)
end

local function is_option_set(name)
    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return false
    end

    if s_current_options[name] == nil then
        return s_current_options[name]
    end

    if s_registered_options[name] == nil then
        return s_registered_options[name]
    end
end

local function set_option(name, value)
    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return false
    end

    local existing = s_current_options[name]
    if existing == nil then
        s_current_options[name] = {
            value=value
        }
        cmd[[doautocmd User VimrcOptionSet]]
    elseif existing.value ~= value then
        existing.value = value
        cmd[[doautocmd User VimrcOptionSet]]
    end
end

function M.get_option(name)
    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return nil
    end

    if s_current_options[name] ~= nil then
        return s_current_options[name].value
    end

    if s_registered_options[name] ~= nil then
        return s_registered_options[name].default
    end
end

function M.register_option(name, type_info, default, source)
    if s_registered_options[name] ~= nil then
        log.error("options", "This option is already registered: " .. name)
        return
    end

    s_registered_options[name] = {
        default=default,
        type_info=type_info,
        source=source
    }
end

function M.set(option_str)
    if option_str == "" then
        echo_options()
        return
    end

    local cmps = string.split(option_str, "=")
    local name = cmps[1]

    if is_option_registered(name) == false then
        log.error("options", "This option is not registered: " .. name)
        return nil
    end

    local value = nil
    if #cmps == 2 then
        value = cmps[2]
    end

    if value == nil then
        log.info(get_option_info(name).source, name .. "=" .. tostring(M.get_option(name)))
        return
    end

    local option_info = s_registered_options[name]
    local converted_value = nil
    if option_info.type_info == "bool" then
        converted_value = typing.toboolean(value)
    elseif option_info.type_info == "int" then
        converted_value = tonumber(value)
    elseif option_info.type_info == "string" then
        converted_value = tostring(value)
    end

    if converted_value == nil then
        log.error("options", "Cannot convert `" .. value .. "` to bool.")
        return
    end

    set_option(name, converted_value)
end

function M.list_options(arg_lead)
    local options = {}

    for key,_ in pairs(s_registered_options) do
        if string.match(key, "^" .. arg_lead) then
            table.insert(options, key)
        end
    end

    return options
end

function M.register_callback(option_name, func)
    assert(s_callbacks[option_name] == nil)

    s_callbacks[option_name] = func
end

return M
