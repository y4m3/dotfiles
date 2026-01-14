#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; Global settings
; ============================================================
SetTitleMatchMode 2  ; Allow partial title matches in WinTitle parameters

; Opacity bounds (0-255). Keep minimum >= 40 to remain visible/usable.
global MIN_OPACITY := 40
global MAX_OPACITY := 255

; SandS state
global SpaceDown := false
global SpacePressTime := 0
global SPACE_THRESHOLD := 200  ; ms - Space sent only if held shorter than this

; jj/jk escape timing (for Vim-style insert mode exit)
global JJ_THRESHOLD := 200  ; milliseconds
global lastJPress := 0

; ============================================================
; SandS (Space and Shift)
; ============================================================
/*
*Space::{
    ; If modifier key is held, send normal Space
    if GetKeyState("Ctrl") || GetKeyState("Alt") || GetKeyState("LWin") || GetKeyState("RWin") {
        Send "{Blind}{Space}"
        return
    }

    Send "{Blind}{Shift down}"
    KeyWait "Space"
    Send "{Blind}{Shift up}"

    ; Send Space only if Space was pressed alone
    if (A_PriorKey = "Space") {
        Send "{Space}"
    }
}
*/

*Space::{
    global SpaceDown, SpacePressTime

    ; If modifier key is held, send normal Space
    if GetKeyState("Ctrl") || GetKeyState("Alt") || GetKeyState("LWin") || GetKeyState("RWin") {
        Send "{Blind}{Space}"
        return
    }

    SpaceDown := true
    SpacePressTime := A_TickCount
    Send "{Blind}{Shift down}"
}

*Space up::{
    global SpaceDown, SpacePressTime, SPACE_THRESHOLD

    if !SpaceDown
        return

    Send "{Blind}{Shift up}"

    ; Send Space only if pressed alone AND held shorter than threshold
    if (A_PriorKey = "Space") && (A_TickCount - SpacePressTime < SPACE_THRESHOLD) {
        Send "{Space}"
    }

    SpaceDown := false
}

; ============================================================
; RAlt for IME control
; ============================================================
; RAlt tap toggles IME, hold acts as normal Alt
~RAlt up::{
    if (A_PriorKey = "RAlt") {
        ImeToggle()
    }
}

; ============================================================
; App groups (context-sensitive hotkeys)
; ============================================================
GroupAdd "Editor", "ahk_exe Code.exe"
GroupAdd "Editor", "ahk_exe Cursor.exe"
GroupAdd "Editor", "ahk_exe Heynote.exe"
GroupAdd "Editor", "ahk_exe Obsidian.exe"
GroupAdd "Editor", "ahk_exe WindowsEditor.exe"
GroupAdd "Editor", "ahk_exe WindowsTerminal.exe"
GroupAdd "Editor", "ahk_exe Zed.exe"
GroupAdd "Editor", "ahk_exe alacritty.exe"
GroupAdd "Editor", "ahk_exe wezterm-gui.exe"

; ============================================================
; Hotstrings
; ============================================================

; Expand ";today" into YYYY-MM-DD (local time)
:?:;today::{
    Send FormatTime(A_Now, "yyyy-MM-dd")
}

; ============================================================
; Hotkeys: IME control for Vim-like workflows (Editor group)
; ============================================================
#HotIf WinActive("ahk_group Editor")

Esc::ImeEsc()            ; ESC: ensure IME OFF if it was ON
^vkDB::ImeEsc()          ; Ctrl+[ (VK-based): same behavior as ESC

vk1D::ImeOff()           ; Muhenkan (JP layout): IME OFF
vk1C::ImeOn()            ; Henkan   (JP layout): IME ON
!`::ImeToggle()          ; Alt+`: fallback IME toggle (useful on US layout)

; jj / jk to escape (Vim-style, only when IME is ON)
~j::{
    global lastJPress, JJ_THRESHOLD
    if IME_Get() && (A_TickCount - lastJPress < JJ_THRESHOLD) {
        EscapeFromInsert()
    }
    lastJPress := A_TickCount
}

~k::{
    global lastJPress, JJ_THRESHOLD
    if IME_Get() && (A_TickCount - lastJPress < JJ_THRESHOLD) {
        EscapeFromInsert()
    }
}

#HotIf

; ============================================================
; Hotkeys: App toggles
; ============================================================

; Toggle Alacritty (show/activate <-> minimize)
; ^+h::ToggleWindowExe("alacritty.exe", "C:\Program Files\Alacritty\alacritty.exe")

; Toggle wezterm (show/activate <-> minimize)
^+h::ToggleWindowExe("wezterm-gui.exe", A_ProgramFiles "\WezTerm\wezterm-gui.exe")
; !Enter::ToggleWindowExe("wezterm-gui.exe", A_ProgramFiles "\WezTerm\wezterm-gui.exe")

; Toggle Ferdium (show/activate <-> minimize)
^+j::ToggleWindowExe("Ferdium.exe", EnvGet("LOCALAPPDATA") "\Programs\Ferdium\Ferdium.exe")

; Toggle Heynote (show/activate <-> minimize)
^+m::ToggleWindowExe("Heynote.exe", EnvGet("LOCALAPPDATA") "\Programs\Heynote\Heynote.exe")

; ============================================================
; Hotkeys: Window opacity (active window)
; ============================================================
; Alt + WheelUp/Down changes opacity; Alt + Middle resets to 100%
!WheelUp::AdjustOpacity(+5)
!WheelDown::AdjustOpacity(-5)
!MButton::SetOpacity(255)

; ============================================================
; IME helpers
; ============================================================

; jj/jk escape from insert mode (only called when IME is ON)
EscapeFromInsert() {
    Send "{Esc}"       ; Cancel uncommitted characters
    Sleep 10
    IME_Set(0)
    Send "{Esc}"       ; Enter normal mode
}

; ESC-like behavior:
; - If IME is ON: send ESC, then turn IME OFF (prevents "stuck IME" in Normal mode)
; - If IME is OFF: just send ESC
ImeEsc() {
    if IME_Get() {
        Send "{Esc}"
        Sleep 10
        IME_Set(0)
    } else {
        Send "{Esc}"
    }
}

ImeOff() => IME_Set(0)
ImeOn()  => IME_Set(1)
ImeToggle() => IME_Set(IME_Get() ? 0 : 1)

; Returns 1 if IME is ON, else 0
IME_Get(winTitle := "A") {
    hwnd := GetFocusedHwnd(winTitle)
    imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")

    ; WM_IME_CONTROL (0x0283), IMC_GETOPENSTATUS (0x0005)
    return DllCall("SendMessageW"
        , "Ptr",  imeWnd
        , "UInt", 0x0283
        , "Ptr",  0x0005
        , "Ptr",  0
        , "Ptr")
}

; Sets IME state: setSts = 1 (ON) / 0 (OFF)
IME_Set(setSts, winTitle := "A") {
    hwnd := GetFocusedHwnd(winTitle)
    imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")

    ; WM_IME_CONTROL (0x0283), IMC_SETOPENSTATUS (0x0006)
    return DllCall("SendMessageW"
        , "Ptr",  imeWnd
        , "UInt", 0x0283
        , "Ptr",  0x0006
        , "Ptr",  setSts
        , "Ptr")
}

; Prefer the focused control HWND (hwndFocus) when available.
; This is more reliable than the top-level window HWND for IME queries.
GetFocusedHwnd(winTitle := "A") {
    hwnd := WinGetID(winTitle)

    if WinActive(winTitle) {
        cbSize := 4 + 4 + (A_PtrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)

        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI.Ptr) {
            focused := NumGet(stGTI, 8 + A_PtrSize, "Ptr")  ; hwndFocus
            if focused
                hwnd := focused
        }
    }
    return hwnd
}

; ============================================================
; Window toggle helpers
; ============================================================

; Toggle window for an executable:
; - If not running: launch and wait for a window
; - If active: minimize and return focus to previous window
; - Else: restore (if minimized) and activate
ToggleWindowExe(exeName, exePath, waitSec := 2) {
    static busy := false
    static lastHwnd := 0

    if busy
        return
    busy := true
    Critical "On"

    try {
        prevHwnd := WinGetID("A")
        hwnd := FindWindowByExe(exeName, lastHwnd)

        if !hwnd {
            Run '"' exePath '"'
            if !WinWait("ahk_exe " exeName, , waitSec)
                return
            hwnd := FindWindowByExe(exeName, 0)
            if !hwnd
                return
        }

        lastHwnd := hwnd

        if WinActive("ahk_id " hwnd) {
            WinMinimize("ahk_id " hwnd)
            if prevHwnd && (prevHwnd != hwnd)
                WinActivate("ahk_id " prevHwnd)
        } else {
            if WinGetMinMax("ahk_id " hwnd) = -1
                WinRestore("ahk_id " hwnd)

            WinShow("ahk_id " hwnd)
            WinActivate("ahk_id " hwnd)
            WinWaitActive("ahk_id " hwnd, , 1)
        }
    } finally {
        Critical "Off"
        busy := false
    }
}

; Returns a window HWND belonging to exeName.
; If preferredHwnd is provided, validate it by process name before using it.
FindWindowByExe(exeName, preferredHwnd := 0) {
    exeLower := StrLower(exeName)

    if preferredHwnd && WinExist("ahk_id " preferredHwnd) {
        try {
            if StrLower(WinGetProcessName("ahk_id " preferredHwnd)) = exeLower
                return preferredHwnd
        }
    }

    list := WinGetList("ahk_exe " exeName)
    if list.Length = 0
        return 0

    ; Usually the first entry is topmost in Z-order.
    return list[1]
}

; ============================================================
; Window opacity helpers (active window)
; ============================================================

AdjustOpacity(delta, hwnd := 0) {
    hwnd := hwnd ? hwnd : WinGetID("A")

    cur := WinGetTransparent("ahk_id " hwnd)
    if (cur = "")
        cur := 255  ; Default to fully opaque when no transparency is set

    next := Clamp(cur + delta, MIN_OPACITY, MAX_OPACITY)
    WinSetTransparent next, "ahk_id " hwnd
    ShowOpacityTip(next)
}

SetOpacity(value, hwnd := 0) {
    hwnd := hwnd ? hwnd : WinGetID("A")
    value := Clamp(value, MIN_OPACITY, MAX_OPACITY)
    WinSetTransparent value, "ahk_id " hwnd
    ShowOpacityTip(value)
}

ShowOpacityTip(alpha) {
    pct := Round(alpha * 100 / 255)
    ToolTip "Opacity: " pct "% (" alpha ")"
    SetTimer () => ToolTip(), -800
}

Clamp(x, lo, hi) => Min(Max(x, lo), hi)

