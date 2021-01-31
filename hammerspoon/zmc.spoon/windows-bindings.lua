-- Default keybindings for WindowLayout Mode
--
-- To customize the key bindings for WindowLayout Mode, create a copy of this
-- file, save it as `windows-bindings.lua`, and edit the table below to
-- configure your preferred shortcuts.
--------------------------------------------------------------------------------
-- Define WindowLayout Mode
--
-- WindowLayout Mode allows you to manage window layout using keyboard shortcuts
-- that are on the home row, or very close to it. Use Control+s to turn
-- on WindowLayout mode. Then, use any shortcut below to perform a window layout
-- action. For example, to send the window left, press and release
-- Control+s, and then press h.
--------------------------------------------------------------------------------
return {
    modifiers = {'alt'},
    showHelp = false,
    trigger = 'w',
    mappings = {
        {
            {}, -- Modifier
            'd', -- Trigger
            'close', -- Function name
            true -- Whether the commands auto disables the mode.
        }, {{}, 'return', 'maximize', true},
        {{'shift'}, 'c', 'centerWithFullHeight', true},
        {{}, 'c', 'center', true}, {{'shift'}, 'w', 'expandCenter', true},
        {{'shift'}, 'a', 'left', true}, {{}, 's', 'down', true},
        {{}, 'w', 'up', true}, {{'shift'}, 'd', 'right', true},
        {{}, 'a', 'leftSameSize', true}, {{}, 'd', 'rightSameSize', true},
        {{}, 'q', 'upLeft', true}, {{}, 'e', 'upRight', true},
        {{}, 'z', 'downLeft', true}, {{}, 'x', 'downRight', true},
        {{}, '1', 'setDefaultTerminalSize', true},
        {{'shift'}, '\\', 'stretchHeight', true},
        {{}, '[', 'tileLeftHalfScreen', true},
        {{}, ']', 'tileRightHalfScreen', true},
        {{}, '=', 'tileFullScreen', true}, {{'shift'}, '=', 'tileGrid', true},
        {{'shift'}, '-', 'tileCenter', true}, {{}, 's', 'saveWindow', true},
        {{}, 'm', 'enableMarkWindowMode', false},
        {{}, 'r', 'enableRestoreWindowMode', false}
    }
}

