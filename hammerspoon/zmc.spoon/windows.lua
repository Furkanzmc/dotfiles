local hs = hs
-- TODO:
--     [ ] Restore window size.
hs.window.animationDuration = 0.2

local g_windowLayoutMode = hs.hotkey.modal.new({}, "F16")

local s_window_mappings = dofile(hs.spoons.resourcePath("windows-bindings.lua"))
local s_modifiers = s_window_mappings.modifiers
local s_show_help = s_window_mappings.showHelp
local s_trigger = s_window_mappings.trigger
local s_mappings = s_window_mappings.mappings
local eventtap = require("hs.eventtap")

local function exit_window_layout_mode()
    g_windowLayoutMode:exit()
end

eventtap
    .new({ eventtap.event.types.keyDown }, function(_)
        return false
    end)
    :start()

-----------------------------------------

local function get_windows(win)
    local wf = hs.window.filter
    wf = wf.default:setAppFilter(win:application():name(), {
        visible = true,
        fullscreen = false,
        currentSpace = true,
    })
    -- FIXME: I could not make the filtering take care of the windows selection.
    -- This solution works, but it'd be cleaner to use the API.
    local windows = {}

    for _, v in pairs(wf:getWindows()) do
        if v:application() == win:application() and v:screen() == win:screen() then
            table.insert(windows, v)
        end
    end

    return windows
end

function hs.window.tile_horizontal(win)
    local windows = get_windows(win)
    local max = win:screen():frame()

    if #windows > 1 then
        hs.window.tiling.tileWindows(windows, hs.geometry(max.x, max.y, max.w, max.h), 0, true)
    end
end

function hs.window.tile_left_half(win)
    local windows = get_windows(win)
    local max = win:screen():frame()

    if #windows > 1 then
        hs.window.tiling.tileWindows(windows, hs.geometry(max.x, max.y, max.w / 2, max.h), 0, true)
    end
end

function hs.window.tile_right_half(win)
    local windows = get_windows(win)
    local max = win:screen():frame()

    if #windows > 1 then
        hs.window.tiling.tileWindows(
            windows,
            hs.geometry(max.w / 2, max.y, max.w / 2, max.h),
            0,
            true
        )
    end
end

function hs.window.tile_vertical(win)
    local max = win:screen():frame()
    local windows = get_windows(win)

    if #windows > 1 then
        hs.window.tiling.tileWindows(windows, hs.geometry(max.x, max.y, max.w, max.h), 100, true)
    end
end

-- +-----------------+
-- |        |        |
-- |  HERE  |        |
-- |        |        |
-- +-----------------+
function hs.window.left(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end

function hs.window.left_same_size(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    win:setFrame(f)
end

-- +-----------------+
-- |        |        |
-- |        |  HERE  |
-- |        |        |
-- +-----------------+
function hs.window.right(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end

function hs.window.right_same_size(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = (max.x + max.w) - f.w
    f.y = max.y
    win:setFrame(f)
end

-- +-----------------+
-- |      HERE       |
-- +-----------------+
-- |                 |
-- +-----------------+
function hs.window.up(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.w = max.w
    f.y = max.y
    f.h = max.h / 2
    win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- +-----------------+
-- |      HERE       |
-- +-----------------+
function hs.window.down(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.w = max.w
    f.y = max.y + (max.h / 2)
    f.h = max.h / 2
    win:setFrame(f)
end

-- +--------------+
-- |  |        |  |
-- |  |  HERE  |  |
-- |  |        |  |
-- +---------------+
function hs.window.center_full_height(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()
    local is_wide = max.w > 1920

    if is_wide then
        f.w = max.w * 0.45
    else
        f.w = max.w * 0.6
    end
    f.h = max.h
    f.x = max.x + (max.w / 2) - f.w / 2
    f.y = max.y
    win:setFrame(f)
end

-- +--------------+
-- |    |    |    |
-- |    |HERE|    |
-- |    |    |    |
-- +---------------+
function hs.window.center_narrow(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()
    local is_wide = max.w > 1920

    if is_wide then
        f.w = max.w * 0.3
    else
        f.w = max.w * 0.325
    end
    f.h = max.h
    f.x = max.x + (max.w / 2) - f.w / 2
    f.y = max.y
    win:setFrame(f)
end

-- +------------------+
-- | |              | |
-- | |  HERE        | |
-- | |              | |
-- +-------------------+
function hs.window.center_wide(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()
    local is_wide = max.w > 1920

    if is_wide then
        f.w = max.w * 0.7
    else
        f.w = max.w * 0.8
    end
    f.h = max.h
    f.x = max.x + (max.w / 2) - f.w / 2
    f.y = max.y
    win:setFrame(f)
end

function hs.window.center(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x + (max.w / 2) - f.w / 2
    f.y = max.y + (max.h / 2) - f.h / 2
    win:setFrame(f)
end

-- +--------------+
-- |    |    |    |
-- |    |HERE|    |
-- |    |    |    |
-- +---------------+
function hs.window.stretch_vertical(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.w = f.w
    f.h = max.h
    f.x = f.x
    f.y = max.y
    win:setFrame(f)
end

-- +--------------+
-- |              |
-- ||    HERE    ||
-- |              |
-- +---------------+
function hs.window.stretch_horizontal(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.w = max.w
    f.x = max.x
    win:setFrame(f)
end

function hs.window.maximize(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.w = max.w
    f.h = max.h
    f.x = max.x
    f.y = max.y
    win:setFrame(f)
end

-- +-----------------+
-- |  HERE  |        |
-- +--------+        |
-- |                 |
-- +-----------------+
function hs.window.up_left(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()
    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- +--------+        |
-- |  HERE  |        |
-- +-----------------+
function hs.window.down_left(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x
    f.y = max.y + (max.h / 2)
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- |        +--------|
-- |        |  HERE  |
-- +-----------------+
function hs.window.down_right(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x + (max.w / 2)
    f.y = max.y + (max.h / 2)
    f.w = max.w / 2
    f.h = max.h / 2

    win:setFrame(f)
end

-- +-----------------+
-- |        |  HERE  |
-- |        +--------|
-- |                 |
-- +-----------------+
function hs.window.up_right(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end

g_windowLayoutMode.entered = function()
    g_windowLayoutMode.statusMessage:show()
end
g_windowLayoutMode.exited = function()
    g_windowLayoutMode.statusMessage:hide()
end

-- Bind the given key to call the given function and exit WindowLayout mode
function g_windowLayoutMode.bindWithAutomaticExit(mode, modifiers, key, fn, autoClose)
    mode:bind(modifiers, key, function()
        fn()

        if autoClose then
            exit_window_layout_mode()
        end
    end)
end

local function getModifiersStr(modifiers)
    local modMap = { shift = "⇧", ctrl = "⌃", alt = "⌥", cmd = "⌘" }
    local retVal = ""

    for _, v in ipairs(modifiers) do
        retVal = retVal .. modMap[v]
    end

    return retVal
end

local msgStr = getModifiersStr(s_modifiers)
msgStr = "Window Layout Mode ("
    .. msgStr
    .. (string.len(msgStr) > 0 and "+" or "")
    .. s_trigger
    .. ")"

for _, mapping in ipairs(s_mappings) do
    local modifiers, trigger, winFunction, autoClose = table.unpack(mapping)
    local hotKeyStr = getModifiersStr(modifiers)

    if s_show_help == true then
        if string.len(hotKeyStr) > 0 then
            msgStr = msgStr .. (string.format("\n%10s+%s => %s", hotKeyStr, trigger, winFunction))
        else
            msgStr = msgStr .. (string.format("\n%11s => %s", trigger, winFunction))
        end
    end

    g_windowLayoutMode:bindWithAutomaticExit(modifiers, trigger, function()
        -- example: hs.window.focusedWindow():upRight()
        local fw = hs.window.focusedWindow()
        hs.window[winFunction](fw)
    end, autoClose)
end

local message = dofile(hs.spoons.resourcePath("status-message.lua"))
g_windowLayoutMode.statusMessage = message.new(msgStr)

-- Use modifiers+trigger to toggle WindowLayout Mode
hs.hotkey.bind(s_modifiers, s_trigger, function()
    g_windowLayoutMode:enter()
end)

g_windowLayoutMode:bind(s_modifiers, s_trigger, function()
    exit_window_layout_mode()
end)
