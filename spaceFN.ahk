#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#InstallKeybdHook
; #Warn  ; Enable warnings to assist with detecting common errors.
; not compatible with spaceFN scripts SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetKeyDelay, -1
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;SetCapsLockState, alwaysoff

;CapsLock::CapsLock

;+ScrollLock::NumLock

CapsLock::
	Send {ESC}
	SetCapsLockState, alwaysoff
	return

RCtrl::F11

#IfWinActive Kindle
XButton1::PgDn
MButton::PgUp
#IfWinActive

XButton1::^v
;Ctrl & Space:: Send #{Space}

;SpaceFn
#inputlevel,1
;movement keys
F24 & k::Up
F24 & j::Down
F24 & h::Left
F24 & l::Right
F24 & i::Home
F24 & o::End
F24 & u::PgUp
F24 & m::PgDn

;editing
F24 & `;::Backspace
F24 & '::Delete
F24 & Backspace::Delete

; copy and paste
F24 & y::^c
F24 & p::^v
F24 & n::^x
F24 & [::ScrollLock
F24 & ]::Pause

; Fn keys
F24 & 1::F1
F24 & 2::F2
F24 & 3::F3
F24 & 4::F4
F24 & 5::F5
F24 & 6::F6
F24 & 7::F7
F24 & 8::F8
F24 & 9::F9
F24 & 0::F10
F24 & -::F11
F24 & =::F12

; other key mappings
F24 & <::send {Volume_Down}
F24 & >::send {Volume_Up}

; spaceFN
; 1. press space, hit another key before release space within 200ms, send space
;    then send the key hit
; 2. press space and release within 200ms, send space
; 3. press space and release after 200ms, do nothing
; 4. press space and hit another key after 200ms, send combination
#inputlevel,2
#MaxThreadsPerHotkey 10
$Space up::
	if (supressSpace=0)
		SendInput {Space}

#MaxThreadsPerHotkey 1
$Space::
    SendLevel, 1
    supressSpace=0
    broken = 0
    Input pressKey, L1T0.2
    ;TrayTip, o%pressKey%o, ooo
    if(pressKey != "") {
        broken = 1
        GetKeystate,sDown,Space,P
        if (sDown = "U") {
            Send {Blind}{%pressKey%}
            broken = 2
        } else {
	    supressSpace=1
            Send {Blind}{Space}{%pressKey%}
	    broken=2
	}
    } else {
        GetKeystate,sDown,Space,P
        if (sDown = "U") {
	    ;Send {Blind}{Space}
            broken = 2
        }
    }
    ;MsgBox o%pressKey%o%broken%o
    if(broken = 0) {
	Send {Blind}{F24 DownR}
	supressSpace=1
	GetKeystate,spaceDown,Space,P
	if (spaceDown = "D") {
		KeyWait, Space
		;MsgBox, O O%pressKey%o-%A_ThisHotkey%-%A_TimeSinceThisHotkey%
	        Send {Blind}{F24 up}
	} else {
	        Send {Blind}{F24 up}
        }
    }
    return
