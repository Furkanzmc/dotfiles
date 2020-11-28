; Map Capslock to Control
; Map press & release of Capslock with no other key to Esc
; Press both shift keys together to toggle Capslock
; Script taken from: https://github.com/fenwar/ahk-caps-ctrl-esc/blob/master/AutoHotkey.ahk

global WindowJumpMap := {}
global WindowGeometries := {}

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

ToggleWindowsDefaultAppMode() {
    RegRead, appMode, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme
    RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme, % !appMode
    RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, SystemUsesLightTheme, % !appMode
    if appMode
    {
        Run, pwsh -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -Command "Set-Item -Path env:PSModulePath -Value '$env:PSModulePath;~/.dotfiles/pwsh/modules/' && Import-Module Pwsh-Utils -DisableNameChecking && Set-Content -Path ~/.dotfiles/pwsh/tmp_dirs/system_theme -Value dark && Set-Terminal-Theme dark"
    }
    else
    {
        Run, pwsh -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -Command "Set-Item -Path env:PSModulePath -Value '$env:PSModulePath;~/.dotfiles/pwsh/modules/' && Import-Module Pwsh-Utils -DisableNameChecking && Set-Content -Path ~/.dotfiles/pwsh/tmp_dirs/system_theme -Value light && Set-Terminal-Theme light"
    }
}

LAlt & h::Left
LAlt & l::Right
LAlt & j::Down
LAlt & k::Up
LCtrl & j::Enter

GetWorkArea()
{
    SysGet, WorkArea, MonitorWorkArea

    area := {}
    area.x := WorkAreaLeft
    area.y := WorkAreaTop
    area.width := WorkAreaRight
    area.height := WorkAreaBottom - WorkAreaTop

    return area
}

; Centers the window with the same width and height.
CenterWindow(WinId, sizeMultiplier)
{
    WinGetPos,,, Width, Height, ahk_id %WinId%
    WorkArea := GetWorkArea()

    If sizeMultiplier > 0
    {
        WinMove, ahk_id %WinId%,, (WorkArea.width / 2) - ((WorkArea.width * sizeMultiplier) / 2), (WorkArea.height / 2) - (WorkArea.height / 2) + WorkArea.y, WorkArea.width * sizeMultiplier, WorkArea.height
    }
    else
    {
        WinMove, ahk_id %WinId%,, (WorkArea.width / 2) - (Width / 2), (WorkArea.height / 2) - (Height / 2) + WorkArea.y
    }
}

; Moves the window to the left with the same width and height.
MoveWindowToLeft(WinId)
{
    WinGetPos,,, Width, Height, ahk_id %WinId%
    WorkArea := GetWorkArea()
    WinMove, ahk_id %WinId%,, 0, (WorkArea.height / 2) - (Height / 2) + WorkArea.y
}

; Moves the window to the right with the same width and height.
MoveWindowToRight(WinId)
{
    WinGetPos,,, Width, Height, ahk_id %WinId%
    WorkArea := GetWorkArea()
    WinMove, ahk_id %WinId%,, WorkArea.width - Width, (WorkArea.height / 2) - (Height / 2) + WorkArea.y
}

ExpandWindow(WinId, vertical)
{
    WinGetPos,,, Width, Height, ahk_id %WinId%
    WorkArea := GetWorkArea()

    If vertical = 1
    {
        WinMove, ahk_id %WinId%, , , (WorkArea.height / 2) - (WorkArea.height / 2) + WorkArea.y, , WorkArea.height
    }
    else
    {
        WinMove, ahk_id %WinId%,, (WorkArea.width / 2) - (Width / 2), (WorkArea.height / 2) - (Height / 2) + WorkArea.y, WorkArea.width,
    }
}

LAlt & c::
    id := WinExist("A")
    if GetKeyState("LShift")
    {
        CenterWindow(id, 0.6)
    }
    else
    {
        CenterWindow(id, 0)
    }
    return

LAlt & w::
    id := WinExist("A")
    if GetKeyState("LShift")
    {
        CenterWindow(id, 0.8)
    }
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
        MoveWindowToLeft(id)
    }
    return

LAlt & d::
    id := WinExist("A")
    MoveWindowToRight(id)
    return

LAlt & |::
    id := WinExist("A")
    ExpandWindow(id, 1)
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
            WindowJumpMap[OutputVar] := id
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
        if Length = 0
        {
            return
        }

        rPressed := OutputVar = "r"
        if rPressed = 1
        {
            id := WinExist("A")
            geometry := WindowGeometries[%id%]
            WinMove, ahk_id %id%,, geometry.x, geometry.y, geometry.width, geometry.height
        }
        else
        {
            id := WindowJumpMap[OutputVar]
            WinActivate, ahk_id %id%
        }
    }
    return

LAlt & p::
    if GetKeyState("LShift")
    {
        id := WinExist("A")

        WinGetPos, X, Y, Width, Height, ahk_id %id%
        geometry := {}
        geometry.x := X
        geometry.y := Y
        geometry.width := Width
        geometry.height := Height
        WindowGeometries[%id%] := geometry
    }

    return

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

LAlt & o::
    if GetKeyState("LShift")
    {
        ToolTip, Press any key to perform custom functions.
        Input, OutputVar, L1 M
        ToolTip

        StringLen, Length, OutputVar
        if Length = 0
        {
            return
        }

        if (OutputVar == "t")
        {
            ToggleWindowsDefaultAppMode()
            return
        }
        else if (OutputVar == "p")
        {
            Run, pwsh, %A_Desktop%
            return
        }
    }

    return
