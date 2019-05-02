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
    showHelp  = false,
    trigger   = 'w',
    mappings  = {
        { {},         'd',      'close' },
        { {},         'return', 'maximize' },
        { {'shift'},  'c',      'centerWithFullHeight' },
        { {},         'c',      'center' },
        { {},         'h',      'left' },
        { {},         'j',      'down' },
        { {},         'k',      'up' },
        { {},         'l',      'right' },
        { {'shift'},  'h',      'leftSameSize' },
        { {'shift'},  'l',      'rightSameSize' },
        { {},         '1',      'setDefaultTerminalSize' },
        { {'shift'},  '\\',     'stretchHeight' },
        { {'shift'},  '-',      'stretchWidth' },
        { {},         '[',      'tileLeftHalfScreen' },
        { {},         ']',      'tileRightHalfScreen' },
        { {},         '=',      'tileFullScreen' },
        { {'shift'},  '=',      'tileGrid' }
    }
}

