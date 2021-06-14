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
        {{'shift'}, 'c', 'center_full_height', true},
        {{'shift'}, 'n', 'center_narrow', true},
        {{}, 'c', 'center', true}, {{'shift'}, 'w', 'center_wide', true},
        {{'shift'}, 'a', 'left', true}, {{}, 's', 'down', true},
        {{}, 'w', 'up', true}, {{'shift'}, 'd', 'right', true},
        {{}, 'a', 'left_same_size', true}, {{}, 'd', 'right_same_size', true},
        {{}, 'q', 'up_left', true}, {{}, 'e', 'up_right', true},
        {{}, 'z', 'down_left', true}, {{}, 'x', 'down_right', true},
        {{'shift'}, '-', 'stretch_height', true},
        {{}, '[', 'tile_left_half', true},
        {{}, ']', 'tile_right_half', true},
        {{}, '-', 'tile_horizontal', true},
        {{}, '\\', 'tile_vertical', true}, {{}, 's', 'saveWindow', true},
        {{}, 'm', 'enableMarkWindowMode', false},
        {{}, 'r', 'enableRestoreWindowMode', false}
    }
}

