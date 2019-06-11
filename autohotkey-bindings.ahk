; Map Capslock to Control
; Map press & release of Capslock with no other key to Esc
; Press both shift keys together to toggle Capslock
; Script taken from: https://github.com/fenwar/ahk-caps-ctrl-esc/blob/master/AutoHotkey.ahk

global WindowsMap := {}
*Capslock::
    Send {Blind}{LControl down}
    return

*Capslock up::
    Send {Blind}{LControl up}
    ; Tooltip, %A_PRIORKEY%
    ; SetTimer, RemoveTooltip, 1000
    if A_PRIORKEY = CapsLock
    {
        Send {Esc}
    }
    return

RemoveTooltip() {
    SetTimer, RemoveTooltip, Off
    Tooltip
    return
}

ToggleCaps() {
    ; This is needed because by default, AHK turns CapsLock off before doing Send
    SetStoreCapsLockMode, Off
    Send {CapsLock}
    SetStoreCapsLockMode, On
    return
}

LCtrl & h::Backspace
LCtrl & j::Enter

; Centers the window with the same width and height.
CenterWindow(WinTitle, changeSize)
{
    WinGetPos,,, Width, Height, %WinTitle%
    If changeSize = 1
    {
        WinMove, %WinTitle%,, (A_ScreenWidth / 2) - ((A_ScreenWidth * 0.55) / 2), (A_ScreenHeight / 2) - (A_ScreenHeight / 2), A_ScreenWidth * 0.55, A_ScreenHeight
    }
    else
    {
        WinMove, %WinTitle%,, (A_ScreenWidth / 2) - (Width / 2), (A_ScreenHeight / 2) - (Height / 2)
    }
}

; Moves the window to the left with the same width and height.
MoveWindowToLeft(WinTitle)
{
    WinGetPos,,, Width, Height, %WinTitle%
    WinMove, %WinTitle%,, 0, (A_ScreenHeight / 2) - (Height / 2)
}

; Moves the window to the right with the same width and height.
MoveWindowToRight(WinTitle)
{
    WinGetPos,,, Width, Height, %WinTitle%
    WinMove, %WinTitle%,, A_ScreenWidth - Width, (A_ScreenHeight / 2) - (Height / 2)
}

LAlt & c::
    id := WinExist("A")
    CenterWindow(A, GetKeyState("LShift"))
    return

LAlt & a::
    id := WinExist("A")
    if GetKeyState("LShift")
    {
        ; WARNING: Do not commit this block.
        if WinExist("ahk_exe Alias.exe")
            WinActivate ;
        ; WARNING: Do not commit this block.
    }
    else
    {
        MoveWindowToLeft(A)
    }
    return

LAlt & d::
    id := WinExist("A")
    MoveWindowToRight(A)
    return

LAlt & m::
    if GetKeyState("LShift")
    {
        ToolTip, Press any key to save the window to jump list
        Input, OutputVar, L1 M
        ToolTip

        StringLen, Length, OutputVar
        if Length > 0
        {
            id := WinExist("A")
            WindowsMap[OutputVar] := id
        }
    }
    return

LAlt & r::
    if GetKeyState("LShift")
    {
        ToolTip, Press any key to jump to window
        Input, OutputVar, L1 M
        ToolTip

        StringLen, Length, OutputVar
        if Length > 0
        {
            id := WindowsMap[OutputVar]
            WinActivate, ahk_id %id%
        }
    }
    return
