-- TODO:
--     [ ] Restore window size.

hs.window.animationDuration = 0.2

windowLayoutMode = hs.hotkey.modal.new({}, 'F16')

local status, windowMappings = pcall(require, 'windows-bindings')
local modifiers = windowMappings.modifiers
local showHelp  = windowMappings.showHelp
local trigger   = windowMappings.trigger
local mappings  = windowMappings.mappings
local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")
local _inLayoutMode = false

local _markWindowModeEnabled = false
local _windowToMark = nil
local _windowRestoreModeEnabled = false
local _markedWindows = {}

function exitWindowLayoutMode()
    _markWindowModeEnabled = false
    _windowToMark = nil

    _windowRestoreModeEnabled = false
    windowLayoutMode:exit()
    _inLayoutMode = false
end


eventtap.new({ eventtap.event.types.keyDown }, function(event)
    if (_inLayoutMode == false) then
        return false
    elseif (_inLayoutMode == nil) then
        return false
    end

    local keyCode = event:getKeyCode()
    if (keycodes.map["escape"] == keyCode) then
        exitWindowLayoutMode()
        return true
    end

    if (_markWindowModeEnabled == true) then
        markWindow(_windowToMark, keyCode)
        exitWindowLayoutMode()
        return true
    elseif (_windowRestoreModeEnabled == true) then
        restoreWindow(hs.window.focusedWindow(), keyCode)
        exitWindowLayoutMode()
        return true
    end

    return false
end):start()


-----------------------------------------

function getWindows(win)
    local wf = hs.window.filter
    wf = wf.default:setAppFilter(
        win:application():name(), {
            visible=true,
            fullscreen=false,
            currentSpace=true
        })
    -- FIXME: I could not make the filtering take care of the windows selection.
    -- This solution works, but it'd be cleaner to use the API.
    local windows = {}

    for _,v in pairs(wf:getWindows()) do
        if (v:application() == win:application()) then
            windows[#windows + 1] = v
        end
    end

    return windows
end

function hs.window.tileGrid(win)
    local windows = getWindows(win)
    local max = win:screen():frame()

    if (#windows > 1) then
        hs.window.tiling.tileWindows(
            windows,
            hs.geometry(0, 0, max.w, max.h),
            1,
            true
            )
    end
end

function hs.window.tileFullScreen(win)
    local windows = getWindows(win)
    local max = win:screen():frame()

    if (#windows > 1) then
        hs.window.tiling.tileWindows(
            windows,
            hs.geometry(0, 0, max.w, max.h),
            0,
            true
            )
    end
end

function hs.window.tileLeftHalfScreen(win)
    local windows = getWindows(win)
    local max = win:screen():frame()

    if (#windows > 1) then
        hs.window.tiling.tileWindows(
            windows,
            hs.geometry(0, 0, max.w / 2, max.h),
            0,
            true
            )
    end
end

function hs.window.tileRightHalfScreen(win)
    local windows = getWindows(win)
    local max = win:screen():frame()

    if (#windows > 1) then
        hs.window.tiling.tileWindows(
            windows,
            hs.geometry(max.w / 2, 0, max.w / 2, max.h),
            0,
            true
            )
    end
end

function hs.window.tileCenter(win)
    local windows = getWindows(win)
    local max = win:screen():frame()

    local maxWindowCount = 5.0
    if (#windows < 5) then
        maxWindowCount = 4
    elseif (#windows > 5) then
        maxWindowCount = #windows
    end

    local totalWidth = max.w * (#windows / maxWindowCount)
    if (#windows > 1) then
        hs.window.tiling.tileWindows(
            windows,
            hs.geometry(max.w / 2 - totalWidth / 2, 0, totalWidth, max.h),
            0,
            true
            )
    end
end

function hs.window.setDefaultTerminalSize(win)
    if (win:application():name() ~= 'iTerm2') then
        return
    end

    local f = win:frame()
    local max = win:screen():frame()

    f.y = 0
    f.w = 640
    f.h = max.h
    win:setFrame(f)
end

function hs.window.stretchHeight(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.y = 0
    f.h = max.h
    win:setFrame(f)
end

function getWindowStateIndex(win)
    local foundIndex = -1
    for index, windowState in pairs(_ENV.windowPositions) do
        if (windowState[1] == win:id()) then
            foundIndex = index
            break
        end
    end

    return foundIndex
end

function hs.window.saveWindow(win)
    local frame = win:frame()
    if (_ENV.windowPositions == nil) then
        _ENV.windowPositions = { { win:id(), frame.x, frame.y, frame.w, frame.h } }
    else
        local index = getWindowStateIndex(win)
        if (index == -1) then
            index = #_ENV.windowPositions + 1
        end

        _ENV.windowPositions[index] = { win:id(), frame.x, frame.y, frame.w, frame.h }
    end
end

function hs.window.enableMarkWindowMode(win)
    _markWindowModeEnabled = true
    _windowToMark = win
end

function markWindow(win, keyCode)
    _markedWindows[keyCode] = win
end

function jumpToWindow(keyCode)
    local window = _markedWindows[keyCode]
    if (window) then
        window:focus()
    end
end

function hs.window.enableRestoreWindowMode(win)
    _windowRestoreModeEnabled = true
end

function restoreWindow(win, keyCode)
    if (keyCode ~= keycodes.map["r"]) then
        win = _markedWindows[keyCode]
        if (win ~= nil) then
            win:focus()
        end
        return
    end

    if (_ENV.windowPositions == nil) then
        return
    end

    local foundIndex = getWindowStateIndex(win)
    if (foundIndex == -1) then
        return
    end

    local windowState = _ENV.windowPositions[foundIndex]
    local frame = win:frame()
    frame.x = windowState[2]
    frame.y = windowState[3]
    frame.w = windowState[4]
    frame.h = windowState[5]
    win:setFrame(frame)
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

function hs.window.leftSameSize(win)
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

function hs.window.rightSameSize(win)
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
function hs.window.centerWithFullHeight(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.w = max.w * 0.6
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
function hs.window.expandCenter(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.w = max.w * 0.8
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
function hs.window.upLeft(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()
    f.x = max.x
    f.y = max.y
    f.w = max.w/2
    f.h = max.h/2
    win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- +--------+        |
-- |  HERE  |        |
-- +-----------------+
function hs.window.downLeft(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x
    f.y = max.y + (max.h / 2)
    f.w = max.w/2
    f.h = max.h/2
    win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- |        +--------|
-- |        |  HERE  |
-- +-----------------+
function hs.window.downRight(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x + (max.w / 2)
    f.y = max.y + (max.h / 2)
    f.w = max.w/2
    f.h = max.h/2

    win:setFrame(f)
end

-- +-----------------+
-- |        |  HERE  |
-- |        +--------|
-- |                 |
-- +-----------------+
function hs.window.upRight(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:fullFrame()

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w/2
    f.h = max.h/2
    win:setFrame(f)
end

windowLayoutMode.entered = function()
    windowLayoutMode.statusMessage:show()
end
windowLayoutMode.exited = function()
    windowLayoutMode.statusMessage:hide()
end

-- Bind the given key to call the given function and exit WindowLayout mode
function windowLayoutMode.bindWithAutomaticExit(mode, modifiers, key, fn, autoClose)
    mode:bind(modifiers, key, function()
        fn()

        if (autoClose) then
            exitWindowLayoutMode()
        end
    end)
end

function getModifiersStr(modifiers)
    local modMap = { shift = '⇧', ctrl = '⌃', alt = '⌥', cmd = '⌘' }
    local retVal = ''

    for i, v in ipairs(modifiers) do
        retVal = retVal .. modMap[v]
    end

    return retVal
end

local msgStr = getModifiersStr(modifiers)
msgStr = 'Window Layout Mode (' .. msgStr .. (string.len(msgStr) > 0 and '+' or '') .. trigger .. ')'

for i, mapping in ipairs(mappings) do
    local modifiers, trigger, winFunction, autoClose = table.unpack(mapping)
    local hotKeyStr = getModifiersStr(modifiers)

    if showHelp == true then
        if string.len(hotKeyStr) > 0 then
            msgStr = msgStr .. (
                string.format('\n%10s+%s => %s',
                    hotKeyStr,
                    trigger,
                    winFunction
                    )
                )
        else
            msgStr = msgStr .. (string.format(
                    '\n%11s => %s', trigger, winFunction
                    )
                )
        end
    end

    windowLayoutMode:bindWithAutomaticExit(modifiers, trigger, function()
        --example: hs.window.focusedWindow():upRight()
        local fw = hs.window.focusedWindow()
        hs.window[winFunction](fw)
    end, autoClose)
end

local message = require('status-message')
windowLayoutMode.statusMessage = message.new(msgStr)

-- Use modifiers+trigger to toggle WindowLayout Mode
hs.hotkey.bind(modifiers, trigger, function()
    _inLayoutMode = true
    windowLayoutMode:enter()
end)
windowLayoutMode:bind(modifiers, trigger, function()
    _inLayoutMode = false
    exitWindowLayoutMode()
end)

