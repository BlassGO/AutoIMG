#NoEnv
#SingleInstance Ignore
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines -1

; Import
#include cib.ahk
#include DinoCode.ahk
#include eval.ahk
#include active_script.ahk
#include cell_edit.ahk
#include http.ahk
#include header_color.ahk

; AHK2 configs
;@Ahk2Exe-SetName         AutoIMG
;@Ahk2Exe-SetDescription  General control of Android installations
;@Ahk2Exe-SetCopyright    Copyright (c) since 2023
;@Ahk2Exe-SetCompanyName  By BlassGO
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-AddResource icon.ico, 160
;@Ahk2Exe-AddResource icon.ico, 206
;@Ahk2Exe-AddResource icon.ico, 207
;@Ahk2Exe-AddResource icon.ico, 208

; Ensure Admin permissions
if not A_IsAdmin {
  try {
     if A_IsCompiled
        Run *RunAs "%A_ScriptFullPath%" /restart
     else
        Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
  } catch {
     ExitApp
  }
}
   
; Info
version = 1.0.1
status = Beta
build_date = 06.08.2023

; In case you are going to compile your own version of this Tool put your name here
maintainer_build_author = @BlassGO

original_author = @BlassGO
name = AutoIMG
title := name "/" version
height := 370
weight := 300
my := 10
mx := 10

; Dependencies path
current := A_ScriptDir "\bin"
tools := current "\tools"
extras := current "\extras"

; Needed tools
fastboot := tools "\fastboot.exe"
adb := tools "\adb.exe"
busybox := extras "\busybox"
dummy_img := extras "\dummy.img"

; Global Regex
ip_check := "((^\s*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\s*$)|(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$))"

; Check dependencies
Folders := current "," current "\images," tools "," extras
Files := fastboot "," adb "," busybox "," dummy_img "," tools "\AdbWinApi.dll," tools "\AdbWinUsbApi.dll,"
Files .= current "\images\dev_options.png," current "\images\clean.jpg," current "\images\clean2.jpg," current "\images\support.png," current "\images\usb.png," current "\images\turn_on.png," current "\images\recoverys.png," current "\images\dev_wir.png,"
Loop, parse, Folders, `,
{
   If A_LoopField && !InStr(FileExist(A_LoopField), "D") {
      MsgBox, 262144, WARNING, % "Cant find """ basename(A_LoopField) """ directory"
      ExitApp
   }
}
Loop, parse, Files, `,
{
   If A_LoopField && !InStr(FileExist(A_LoopField), "A") {
      MsgBox, 262144, WARNING, % "Cant find """ basename(A_LoopField) """ file"
      ExitApp
   }
}

; Working PATHs
EnvGet, native, PATH
EnvSet, PATH, % current ";" tools ";" A_ScriptDir ";" native

; Extra info
winver := get_win_ver()     

; Defining and clearing general log
general_log := current "\" name ".log"
if FileExist(general_log)
   FileDelete, % general_log  

; Basic Animations
HIDE := 65536
SHOW := 131072
SLIDE := 262144
FADE := 524288
LEFT_RIGHT := 1
RIGHT_LEFT := 2
TOP_BOTTOM := 4
BOTTOM_TOP := 8
CENTER := 16

; Combined Animations
FADE_SHOW  := FADE + SHOW
FADE_HIDE  := FADE + HIDE
SLIDE_BOTTOM_TOP_HIDE := SLIDE + BOTTOM_TOP + HIDE

; Default Animations
EXIT_ANIM := FADE_HIDE

; Animations need to be Hex
SetFormat, Integer, H
EXIT_ANIM += 0
SetFormat, Integer, D

; Extra Functions
GuiDefaultFont() {
   VarSetCapacity(LF, szLF := 28 + (A_IsUnicode ? 64 : 32), 0) ; LOGFONT structure
   If DllCall("GetObject", "Ptr", DllCall("GetStockObject", "Int", 17, "Ptr"), "Int", szLF, "Ptr", &LF)
      Return {Name: StrGet(&LF + 28, 32), Size: Round(Abs(NumGet(LF, 0, "Int")) * (72 / A_ScreenDPI), 1)
            , Weight: NumGet(LF, 16, "Int"), Quality: NumGet(LF, 26, "UChar")}
   return False
}
GetSysColor( DisplayElement=1 ) {
   VarSetCapacity( HexClr,14,0 ), SClr := DllCall( "GetSysColor", UInt,DisplayElement )
   RGB := ( ( ( SClr & 0xFF) << 16 ) | ( SClr & 0xFF00 ) | ( ( SClr & 0xFF0000 ) >> 16 ) )
   DllCall( "msvcrt\" (A_IsUnicode ? "swprintf" : "sprintf"), Str,HexClr, Str,"%06X", UInt,RGB )
   return HexClr
}
GetFullPathName(path) {
   cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
   VarSetCapacity(buf, cc*(A_IsUnicode?2:1))
   DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
   return buf
}
AnimateWindow(hWnd,Duration,Flag) {
   return DllCall("AnimateWindow","UInt",hWnd,"Int",Duration,"UInt",Flag)
}
LV_SubitemHitTest(HLV) {
   ; To run this with AHK_Basic change all DllCall types "Ptr" to "UInt", please.
   ; HLV - ListView's HWND
   Static LVM_SUBITEMHITTEST := 0x1039
   VarSetCapacity(POINT, 8, 0)
   ; Get the current cursor position in screen coordinates
   DllCall("User32.dll\GetCursorPos", "Ptr", &POINT)
   ; Convert them to client coordinates related to the ListView
   DllCall("User32.dll\ScreenToClient", "Ptr", HLV, "Ptr", &POINT)
   ; Create a LVHITTESTINFO structure (see below)
   VarSetCapacity(LVHITTESTINFO, 24, 0)
   ; Store the relative mouse coordinates
   NumPut(NumGet(POINT, 0, "Int"), LVHITTESTINFO, 0, "Int")
   NumPut(NumGet(POINT, 4, "Int"), LVHITTESTINFO, 4, "Int")
   ; Send a LVM_SUBITEMHITTEST to the ListView
   SendMessage, LVM_SUBITEMHITTEST, 0, &LVHITTESTINFO, , ahk_id %HLV%
   ; If no item was found on this position, the return value is -1
   If (ErrorLevel = -1)
      Return 0
   ; Get the corresponding subitem (column)
   Subitem := NumGet(LVHITTESTINFO, 16, "Int") + 1
   Return Subitem
}
/*
typedef struct _LVHITTESTINFO {
  POINT pt;
  UINT  flags;
  int   iItem;
  int   iSubItem;
  int   iGroup;
} LVHITTESTINFO, *LPLVHITTESTINFO;
*/
text_size(txt, hwnd, font := "", size := "") {
   global style
   len := 0
   lines := CountMatch(txt, "`n")+1
   Loop, Parse, txt, `n
   {
      if A_LoopField && StrLen(A_LoopField)>len {
	     len := StrLen(A_LoopField)
		 txt := A_LoopField
	  }
   }
   if !font
      font := style
   if !size
      size := 10
   if !len
      len := StrLen(txt)
   if !lines
      lines := 1
   hdc := DllCall("GetDC", "UInt", hwnd)
   hfont := DllCall("CreateFont", "Int", -size, "Int", 0, "Int", 0, "Int", 0, "Int", 400, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "Str", font)
   oldfont := DllCall("SelectObject", "UInt", hdc, "UInt", hfont)

   DllCall("GetTextExtentPoint32", "UInt", hdc, "Str", txt, "Int", len, "UInt", &size)
   width := NumGet(size, 0, "Int")
   height := NumGet(size, 4, "Int")

   DllCall("SelectObject", "UInt", hdc, "UInt", oldfont)
   DllCall("DeleteObject", "UInt", hfont)

   DllCall("ReleaseDC", "UInt", hwnd, "UInt", hdc)
   return {w: width, h: height*lines}
}
eventHandler(wParam, lParam, msg, hwnd) {
	static WM_LBUTTONDOWN := 0x201
	, WM_LBUTTONUP := 0x202
	, WM_LBUTTONDBLCLK := 0x203
	, WM_CHAR := 0x102
	, lButtonDownTick := 0
	global clicktime := 0
	global generalbox

	if (msg = WM_LBUTTONDOWN) {
		lButtonDownTick := A_TickCount
	} else if (msg = WM_LBUTTONUP) {
		clicktime := A_TickCount - lButtonDownTick
	} else if (hwnd = generalbox) && (msg = WM_LBUTTONDBLCLK) {
	    gosub console
	}
	return 
}
CountMatch(str, match) {
	_pos:=1,_total:=0,_with:=StrLen(match)
	while,(_pos:=InStr(str,match,,_pos))
	   _total++, _pos+=_with
    return _total
}
unzip(sZip, sUnz, options := "-o", resolve := false) {
    ; Idea by shajul http://www.autohotkey.com/forum/viewtopic.php?t=65401
	; Improved by me (BlassGO)
   global general_log, secure_user_info, current, HERE, TOOL
	static zip_in_use, last_path
	if !sUnz
	   sUnz := A_ScriptDir
	if !resolve {
	    if (options ~= "\binside-zip\b") {
		   RegexMatch(sZip, "^(.*?\.zip)\K.*", back_relative)
		   RegexMatch(sZip, "^(.*?\.zip)", sZip)
		}
		if InStr(FileExist(sZip), "A") {
         if (secure_user_info && !(GetFullPathName(sUnz) ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
            MsgBox, 262148, Unzip preferences, % " Attempting to extracting outside of common paths:`n`n " sUnz "`n`n Do you want to allow it?"
            IfMsgBox No
            {
               return 0
            }
         }
		   if !InStr(FileExist(sUnz), "D")
              FileCreateDir, % sUnz
		   sZip := GetFullPathName(sZip)
		   if back_relative
		      sZip .= back_relative
		   zip_in_use := sZip
		   last_path := sUnz
		} else {
		   write_file("`nUNZIP: Cant find file: """ sZip """`n", general_log)
		   return
		}
	}
	try {
		psh := ComObjCreate("Shell.Application")
		zip := psh.Namespace(sZip)
		back_opt := options
		if RegexMatch(options, "regex:\s*\K.*", regex) {
		   RegexMatch(options, "(.*?)(?=regex:)", options)
		} else if RegexMatch(options, "regex-name:\s*\K.*", regex) {
		   regex_name := true
		   RegexMatch(options, "(.*?)(?=regex-name:)", options)
		} else {
		   regex := ".*"
		}
		if (options ~= "\bfiles|-f\b")
		   allow_files := true
		if (options ~= "\bfolders|-d\b")
		   allow_folders := true
		if (options ~= "\boverwrite|force|-o\b")
		   overwrite := true
		if (options ~= "\bmix-path|-mix|-m\b")
		   mix := true
		if !allow_files&&!allow_folders {
		   allow_files := true
		   allow_folders := true
		}
		for file in zip.items
		{
			if (!allow_folders&&file.IsFolder) {
				unzip(file, sUnz, back_opt, true)
			} else if (allow_files&&allow_folders) || (allow_files&&!file.IsFolder) || (allow_folders&&file.IsFolder) {
				relative_to_zip := StrReplace(file.Path, zip_in_use "\")
				if (regex_name&&RegExMatch(file.Name, regex))||(!regex_name&&RegExMatch(relative_to_zip, regex)) {
					if mix {
					   dest := last_path "\" dirname(relative_to_zip, false)
					} else {
					   dest := last_path
					}
					if !InStr(FileExist(dest), "D")
					   FileCreateDir, % dest
					folder := psh.Namespace(GetFullPathName(dest))
					if overwrite || !FileExist(dest "\" file.Name) {
					   if (GetFullPathName(dest "\" file.Name)=current "\configs.ini") {
					      MsgBox, 262144, Unzip preferences, % " Attempting to replace:`n`n " current "\configs.ini`n`n This action is not allowed for your security"
                          return 0
					   }
					   date_zip := file.ExtendedProperty("System.DateModified")
					   write_file("`nUNZIP: Extracting """ relative_to_zip """ in """ dest """`n", general_log)
					   folder.CopyHere(file, 4|16)
					   Loop {
						   if (FileExist(dest "\" file.Name) && (file.IsFolder||folder.ParseName(file.Name).ExtendedProperty("System.DateModified")==date_zip)) {
							  break
						   }
					   }
					}
				}
			}
		}
	} catch e {
      InStr(e.what, "RegexMatch") ? e.message:="Check your Regex Pattern"
	   MsgBox, 262144, Unzip, % "A fatal error occurred while extracting:`n""" zip_in_use """`n`n" e.message "`n`n--> " e.what
      return 0
	}
   (!resolve) ? (zip_in_use:="", last_path:="")
   return 1
}
basename(str, fullpath := true) {
   if fullpath && FileExist(str) {
      str := GetFullPathName(str)
      SplitPath, str, Name
   } else {
      RegExMatch(str, "(.*[\\/])*\K(.+)$", Name)
   }
   return Name
}
dirname(str, fullpath := true) {
   if fullpath && FileExist(str) {
      str := GetFullPathName(str)
      SplitPath, str,, Dir
   } else {
      RegExMatch(str, "(.*?)(?=[\\/][^\\/]*$)", Dir)
   }
   return Dir
}
extname(str, fullpath := true) {
   if fullpath && FileExist(str) {
      str := GetFullPathName(str)
      SplitPath, str,,,Ext
   } else {
      RegExMatch(str, ".*\.\K(.+)$", Ext)
   }
   return Ext
}
simplename(str, fullpath := true) {
   if fullpath && FileExist(str) {
      str := GetFullPathName(str)
      SplitPath, str,,,,Name,
   } else {
      RegExMatch(str, "(.*[\\/])*\K(.*?)(?=(\.[^.]*)$)", Name)
   }
   return Name
}
get_serial(str, wireless := false) {
   if wireless||!RegexMatch(str, "`am)^([a-zA-Z]*[0-9][a-zA-Z0-9]+?)(?=[ `t])", serial)
      RegexMatch(str, "`am)^((\d{1,3}\.){3}\d{1,3}:\d+?)(?=[ `t])", serial)
   return serial
}
ubasename(str) {
   return RegExReplace(str, ".*/([^/]+)$", "$1")
}
wbasename(str) {
   return RegExReplace(str, ".*\\([^\\]+)$", "$1")
}
shell(action, noroot := "", noescape := "") {
   return RegExReplace(adb_shell(action, noroot, noescape), "m`a)^\s+|\h+$|\s+(?-m)$")
}
check_string(try, str, files := true) {
	(files&&InStr(FileExist(try), "A")) ? try := read_file(try)
	return (try ~= str)
}
write_file(content, file, enc := "") {
   global CONFIG
   global HERE
   global TOOL
   global secure_user_info
   global general_log
   global current
   GetFullPathName(file) ? file := GetFullPathName(file)
   if (file==current "\configs.ini") {
      MsgBox, 262144, Write preferences, % " Attempting to replace:`n`n " file "`n`n This action is not allowed for your security"
      return 0
   }
   if (secure_user_info && !(file ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
	  MsgBox, 262148, Write preferences, % " Attempting to write a file outside of common paths:`n`n " file "`n`n Do you want to allow it?"
	  IfMsgBox No
	  {
	     return 0
	  }
   }
   if !enc
      enc=UTF-8
   try {
      FileAppend, % content, % file, % enc
	  return 1
   } catch {
      FileAppend, % "Cant write in: """ file """, Ended with: " ErrorLevel, % general_log, UTF-8
	  return 0
   }
}
enable_bar() {
   GuiControl, 1:Disable, install
   ;GuiControl, 1:Disable, % HB_Button[1].Hwnd
   GuiControl, 1:Enable, install_bar
}
disable_bar() {
   GuiControl, 1:Disable, install_bar
   GuiControl, 1:, install_bar, 0
   GuiControl, 1:Enable, install
   ;GuiControl, 1:Enable, % HB_Button[1].Hwnd
}
add_progress(progress) {
   GuiControlGet, current, 1:, install_bar
   if (current>=100)
      return
   Loop, % progress
   {
      GuiControl, 1:, install_bar, +1
	  Sleep, 10
   }
}
run_cmd(code, seconds:="") {
   global secure_user_info
   global current
   global tools
   global extras
   global exitcode
   allowed_actions := tools "\adb.exe," tools "\fastboot.exe" "," dirname(comspec) "\certutil.exe,"
   exitcode=
   if secure_user_info {
      Loop, parse, allowed_actions, `,
      {
         if A_LoopField && (code ~= "^\s*([""]*\Q" A_LoopField "\E[""]*)") {
            allowed=1
            break
         }
      }
	  if !allowed || (code ~= "[;%{}()[\]*^><&|](?=[^""\\]*(?:""[^""\\]*""[^""\\]*)*$)") {
         MsgBox, 262148, WARNING, % " Unusual actions attempted:`n`n " code "`n`n Do you want to allow it?"
	     IfMsgBox No
	     {
	        return 0
	     }
      } else {
	     code .= " 2>&1"
	  }
   }
   back := A_DetectHiddenWindows
   DetectHiddenWindows, On
   Run, %comspec% /k,, Hide, cmdpid
   WinWait, ahk_pid %cmdpid%
   DllCall("AttachConsole", "UInt", cmdpid)
   code := comspec . " /c """ . code . """"
   shell := comobjcreate("wscript.shell")
   exec := (shell.exec(code))
   if (seconds ~= "^[1-9][0-9]*$") {
	   SetTimer, cmd_output, % seconds * 1000
	   While (!exec.Status)
	   {
		  Sleep, 100
	   }
	   exitcode := exec.ExitCode
	   SetTimer, cmd_output, Off
   }
   if (result=="") {
      result := exec.stdout.readall()
	  if (exitcode=="")
	     exitcode := exec.ExitCode
   }
   Process, Exist, % cmdpid
   if ErrorLevel {
      DllCall("FreeConsole")
      exec.Terminate()
	  RunWait, taskkill /F /PID %cmdpid%,, Hide
      Process, Close, % cmdpid
   }
   DetectHiddenWindows, % back
   return result
   cmd_output:
   if (exitcode=="") {
	   if (exec.Status==1) {
		  result := exec.stdout.readall()
	   } else {
	      result := 0
	   }
	   DllCall("FreeConsole")
       exec.Terminate()
	   RunWait, taskkill /F /PID %cmdpid%,, Hide
       Process, Close, % cmdpid
   }
   return
}
get_win_ver() {
   if (A_OSVersion ~= "^10\.0\.22")
      return 11
   if (A_OSVersion ~= "^10\.0\.21")
      return 11
   if (A_OSVersion ~= "^10\.0")
      return 10
   if (A_OSVersion ~= "^6\.3")
      return 8.1
   if (A_OSVersion ~= "^(6,2|6\.2)")
      return 8
   if (A_OSVersion ~= "^6\.1")
      return 7
   return Unknown
}
adb(action, seconds:="") {
   global adb
   global secure_user_info
   if !secure_user_info
      action .= " 2>&1"
   result := run_cmd("""" adb """" " " action, seconds)
   return result
}
adb_serial(action, this_serial := "", seconds:="") {
   global serial
   if this_serial {
      result := adb("-s " this_serial " " action, seconds)
   } else if serial {
      result := adb("-s " serial " " action, seconds)
   } else {
      result := 0
   }
   return result
}
adb_shell(action, noroot := "", noescape := "") {
   global PATH
   ensure_shell()
   if !noescape
      action := StrReplace(action, "\", "\\")
   action := StrReplace("export PATH=" """" "$PATH:" PATH """" ";" StrReplace(action, "`r`n"), """", "\""")
   if !noroot
      try := adb_serial("shell " """" "[ -e " "\""" "$(command -v su)" "\""" " ] && echo SU command support" """")
   ensure_shell()
   if InStr(try, "SU command") {
	  result := adb_serial("shell " """su -c " "'" action "'" """")
   } else {
      result := adb_serial("shell " """" action """")
   }
   return result
}
ensure_shell() {
   global adb
   global exist_device
   global device_mode
   global remember_mode
   global general_log
   global serial
   while !InStr(run_cmd("""" adb """" " -s " serial " shell echo pwu"), "pwu")
   {
      if !attemps {
	     print(">> Waiting device shell")
		 attemps := true
	  }
      find_device(1)
   }
}
fastboot(action, seconds := "") {
   global fastboot
   global secure_user_info
   if !secure_user_info
      action .= " 2>&1"
   Process, Close, % basename(fastboot)
   result := run_cmd("""" fastboot """" " " action, seconds)
   return result
}
fastboot_serial(action, this_serial := "", seconds:="") {
   global serial
   if this_serial {
      result := fastboot("-s " this_serial " " action, seconds)
   } else if serial {
      result := fastboot("-s " serial " " action, seconds)
   } else {
      result := 0
   }
   return result
}
is_active(serial) {
   global exist_device
   global device_mode
   global remember_mode
   if !serial
      return 0
   if (remember_mode=="fastboot") {
      result := fastboot("devices")
	  RegexMatch(result, "`am)^(\Q" serial "\E)[ `t]+\S+", result)
	  if (serial!=get_serial(result))
	     result=error
   } else {
      result := adb_serial("get-state", serial)
   }
   if !result
      return 0
   if !InStr(result, "error") {
      exist_device=true
	  device_mode := remember_mode
      return 1
   } else {
      return 0
   }
}
check_active(serial) {
    if !serial
	   return 0
    if !is_active(serial) {
       print(">> Device was disconnected!")
	   return 0
    } else {
	   return 1
	}
}
timed_msg(txt := "", time := "", followover := "") {
   global style
   global toolX
   global toolY
   global toolW
   global toolid
   global timedhwnd
   static text
   Gui new5: +AlwaysOnTop +Owner
   Gui new5: Font, s10, %style%
   if txt {
      Gui new5: Add, Text, x0 y0 hwndtext, % txt
   }
   Gui new5: Show,, timed_msg
   WinSet, Style, -0xC00000, A
   WinSet, Style, -0x40000, A
   WinWait, timed_msg
   WinGet, timedhwnd, ID, timed_msg
   if txt {
      size := text_size(txt, text)
	  Gui new5: Show, % "h" size.h+10
   }
   if followover {
      SetTimer, timed_msg_follow, 10
   }
   if time is integer
   {
      SetTimer, timed_msg_thread, % time
   }
   return
   timed_msg_thread:
   SetTimer, timed_msg_follow, Off
   SetTimer, timed_msg_thread, Off
   Gui new5: Destroy
   return
   timed_msg_follow:
   WinGetPos, toolX, toolY, toolW, toolH, ahk_id %toolid%
   WinGetPos, newX, newY, newW, newH, ahk_id %timedhwnd%
   WinMove, ahk_id %timedhwnd%,, toolX + ((toolW - newW ) // 2), toolY - newH
   return
}
timed_msg_destroy() {
   SetTimer, timed_msg_follow, Off
   Gui new5: Destroy
}
get_bootloader_env() {
   global device_mode
   global exist_device
   global unlocked
   global fastbootd
   global secure
   global current_slot
   global logical_name
   global size_name
   global size
   global super
   global serial
   global current_anti
   Loop % logical_name.MaxIndex() {
      logical.Delete(A_Index)
   }
   Loop % size_name.MaxIndex() {
      size_name.Delete(A_Index)
   }
   Loop % size.MaxIndex() {
      size.Delete(A_Index)
   }
   unlocked =
   fastbootd =
   secure =
   current_slot =
   current_anti =
   super =
   if (serial && !check_active(serial))
      return 0
   if !exist_device
      return 0
   if (device_mode!="fastboot")
      return 0
   get := fastboot_serial("getvar all")
   if !get
      return 0
   logical_name := []
   size_name := []
   size := []
   huh := StrSplit(get, [A_Tab,")","`r","`n",":"])
   Loop % huh.MaxIndex()
   {
      huh[A_Index] := Trim(huh[A_Index], "`n" A_Space "`t")
   }
   Loop % huh.MaxIndex()
   {
        If (huh[A_Index]="unlocked") {
		    if (huh[A_Index+1]="yes") {
			   unlocked := true
			}
		}
		If (huh[A_Index]="is-userspace") {
		    if (huh[A_Index+1]="yes") {
			   fastbootd := true
			}
		}
	    If (huh[A_Index]="secure") {
		    if (huh[A_Index+1]="yes") {
			   secure := true
			}
        }
	    If (huh[A_Index]="current-slot") {
			if (huh[A_Index+1]="a") || (huh[A_Index+1]="b") {
               current_slot := "_" huh[A_Index+1]
			}
		}
		If (huh[A_Index]="anti") {
			if huh[A_Index+1] is integer
			{
               current_anti := huh[A_Index+1]
			}
		}
		If (huh[A_Index]="is-logical") {
			if (huh[A_Index+2]="yes") {
			   super := true
			   logical_count++
               logical_name[logical_count] := huh[A_Index+1]
			}
	    }
		If (huh[A_Index]="partition-size") {
		    raw := huh[A_Index+2]
			SetFormat, Integer, D
			raw += 0
			if raw is integer
			{
			   size_count++
               size_name[size_count] := huh[A_Index+1]
			   if (huh[A_Index+1] ~= "^(system|system_ext|vendor|product|odm)(_a|_b)$") && !is_logical(huh[A_Index+1]) {
			      super := true
			      logical_count++
                  logical_name[logical_count] := huh[A_Index+1]
			   } else if !super && (huh[A_Index+1]="super" || huh[A_Index+1]="SUPER") {
			      super := true
			   }
			   size[size_count] := raw
			}
	    }
   }  
}
is_logical(part) {
   global logical_name  
   Loop % logical_name.MaxIndex() {
      if (logical_name[A_Index]=part)
	     return 1
   }
   return 0
}
is_real(part) {
   global size_name 
   Loop % size_name.MaxIndex() {
      if (size_name[A_Index]=part)
	     return 1
   }
   return 0
}
get_size(part) {
   global size_name
   global size   
   Loop % size_name.MaxIndex() {
      if (size_name[A_Index]=part)
	     return size[A_Index]
   }
   return
}
free_logical(){
   global super
   global logical_name
   if !super
      return 0
   get_bootloader_env()
   subpart_size := 0
   free_logical := 0
   super_size := get_size("super")
   if !super_size {
      print(">> Empty SUPER image!")
      return
   }
   Loop % logical_name.MaxIndex() {
      subpart_size += get_size(logical_name[A_Index])
   }
   if (super_size>subpart_size) {
       ; 1MB reserved for each subpart
       free_logical := (super_size - 1048576 * logical_name.MaxIndex()) - subpart_size
   } else {
      print(">> Abnormal SUPER image!")
      return
   }
   if (free_logical>0) {
      return free_logical
   } else {
      return 0
   }
}
check_free_space(img, part) {
   global mx, my, style, logical_name, dummy_img, super, need, start, partcontrol, free_logical, serial, HeaderColors
   ;Loop, % logical_name.MaxIndex() {
   ;   if list 
   ;	     list .= "|"
   ;   list .= logical_name[A_Index]
   ;}
   if (serial && !check_active(serial))
      return 0
   part_size := get_size(part)
   FileGetSize, img_size, %img%
   free_logical := free_logical()
   if free_logical is not integer
      return 0
   if (is_logical(part) && (img_size>part_size+free_logical)) || (img_size>part_size) {
		 print(">> " basename(img) " bigger than " part " partition")
		 if !super {
            print(">> No dynamic device")
			return 0
         }
		 if !is_logical(part)
		    return 0
	     MsgBox, 262148, WARNING, % basename(img) . " is bigger than the partition " . part " , you want to try to correct it?"
	     IfMsgBox No
		 {
		    print(">> Enabled Force installation")
			GuiControl, 1:, force_install, 1
		    return 1
		 }
   } else {
      return 1
   }
   FileGetSize, dummy_size, %dummy_img%
   needed := img_size - part_size
   back := needed
   Gui 2: Default 
   Gui 2: +AlwaysOnTop
   Gui 2: margin, %mx%, %my%
   Gui 2: Font, s10, %style%
   Gui 2: Add, Text, AltSubmit Y+0 c254EC5 vneed, % "You need " . normal_units(needed)
   Gui 2: Add, ListView, AltSubmit NoSortHdr -LV0x10 LV0x20 Checked gpartcontrol vpartcontrol hwndpartcontrol XS Y+10, |Partition to remove|Size
   Gui 2: Add, Button, AltSubmit center XS Y+10 h20 w100 vstart gstart, START
   LV_Delete()
   Loop, % logical_name.MaxIndex() {
      if (logical_name[A_Index]=part)
	     continue
      size := get_size(logical_name[A_Index])
      If (size<=0)
	     continue
	  LV_Add("", "", logical_name[A_Index], normal_units(size))
   }
   Loop % LV_GetCount("Column")
      LV_ModifyCol(A_Index, "AutoHdr Center")
   HHDR := DllCall("SendMessage", "Ptr", partcontrol, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr") ; LVM_GETHEADER
   HeaderColors[HHDR] := {Txt: 0xFFFFFF, Bkg: 0x797e7f} ; BGR
   SubClassControl(partcontrol, "HeaderCustomDraw")
   Gui 2: show, w320 AutoSize, Partition Manager
   GuiControl, Move, start, x%okay_x%
   WinSet, Redraw, , ahk_id %HHDR%
   WinWaitClose, Partition Manager
   Gui 2: Destroy
   if okay {
      return 1
   } else {
      return 0
   }
   partcontrol:
   If (A_GuiEvent == "I") {
        If (ErrorLevel == "C") {
		    LV_GetText(option, A_EventInfo, 2)
			;ToolTip, % option . " is checked."
			needed -= get_size(option) - dummy_size
			if (needed<=0) {
			   ;GuiControl, hide, need
			   GuiControl,,need, 
			} else {
			   GuiControl,,need, % "You need " . normal_units(needed)
			}
        } else If (ErrorLevel == "c") {
		    LV_GetText(option, A_EventInfo, 2)
			;ToolTip, % option . " is unchecked."
			needed += get_size(option) - dummy_size
			if (needed>back)
			   needed := back
			if (needed>0)
			   GuiControl,,need, % "You need " . normal_units(needed)
	    }
    }
   return
   start:
   If (needed<=0) {
       Gui 2: Hide
       item = 0
       Loop
       {
          item := LV_GetNext(item, "Checked")
          if !item
              break
          LV_GetText(partition, item, 2)
          if !install_img(dummy_img, partition) {
			 okay =
			 Gui 2: Destroy
			 break
		  } else {
		     okay := true
		  }
      }
	  Gui 2: Destroy
   } else {
      MsgBox, 262144, HELP, There is not enough space yet!
   }
   return
   2GuiSize:
   okay_x := (A_GuiWidth - 100) // 2
   okay_y := (A_GuiHeight - 20) // 2
   return
}
normal_units(size) {
   in = GB
   size := size / 1024**3
   if (Floor(size)=0) {
      in = MB
	  size := size * 1024
   }
   if (Floor(size)=0) {
	  in = KB
	  size := size * 1024
   }
   size := Round(size, 2)
   if size is number
      return size . " " . in
   else
      return Unknown
}
find_device(attemps := 1, show_msg := "", show_box := "", show_panel := "") {
   global exist_device, device_mode, device_connection, remember_mode, currentdevice, devices, serial, current
   global wireless_IP, wireless_PORT, hidden_devices, wireless_FORCE
   global style, adb, mx, my, general_log, HeaderColors, ip_check
   exist_device=
   device_mode=
   device_connection=
   serial_n=0
   remember_mode=
   if show_box {
      if hidden_devices
	     print(">> Finding hidden device...")
	  else
         print(">> Finding device...")
   }
   if show_panel {
      if hidden_devices
	     timed_msg("Finding hidden devices...", "", true)
	  else
         timed_msg("Finding devices...", "", true)
   }
   Loop
   {
	   if (A_Index <= attemps) {
	      devices := []
		   currentdevice := ""
		   devicelist := ""
	      result := fastboot("devices")
		   if hidden_devices && !(result ~= "\bfastboot\b") {
			   if (result := fastboot("getvar serialno", 5)) {
			     Loop, Parse, result, `n
              {
			         if RegExMatch(A_LoopField, "serialno:[ `t]*\K\S+", hidden_serial) {
					      devicelist .= hidden_serial " fastboot `n"
					   }
			     }
				  result := devicelist
				  write_file("`n[HIDDEN DEVICES]`n" result "`n", general_log)
			   }
		   }
		   if !(result ~= "\bfastboot\b") {
		      result := adb("start-server")
		      if InStr(result, "daemon started successfully") {
			     write_file("`nADB: Started the server successfully`n[`n" result "`n]`n", general_log)
			  } else {
			     write_file("`nADB: Server in use, resetting...`n", general_log)
				  result := adb("kill-server")
				  result .= adb("start-server")
				  if !InStr(result, "daemon started successfully") {
				    write_file("`nADB: Could not start the server`n[`n" result "`n]`n", general_log)
					 MsgBox, 262144, HELP, Could not start ADB server`n`nCannot continue...
					 return 0
				  }
			  }
			  if wireless_IP {
			      print(">> TCP/IP: Loading...")
			      if !(ip&&port) {
					  if RegExMatch(wireless_IP, "(\b(?:\d{1,3}\.){3}\d{1,3}\b)(?:\s*:\s*(\d+))?", ip) {
						 ip:=ip1,port:=ip2
					  } else if (wireless_IP ~= ip_check) {
					     ip := "[" wireless_IP "]"
					  } else {
					     MsgBox, 262144, HELP, % "Invalid IP: """ wireless_IP """"
						 break
					  }
					  if !port {
						if (wireless_PORT ~= "^\d+$") {
						   port := wireless_PORT
						} else if wireless_PORT {
						   MsgBox, 262144, HELP, % "Invalid PORT: """ wireless_PORT """"
						   break
						}
					  }
					  if (port="") {
						wireless_PORT := port := 5555
						with_usb := true
					  }
				  }
				  if with_usb {
				    (device_connection!="USB") ? help(current "\images\usb.png", "Before pressing ""OK"", please connect your device via USB cable.")
					write_file("`nTCP/IP: Trying to define port", general_log)
					if InStr(adb_serial("tcpip " port), "restarting in TCP") {
					   write_file("`nTCP/IP: PORT was defined as """ port """ successfully`n", general_log)
					   with_usb := false
					   if (adb("connect " ip ":" port, 5) ~= "connected|already") {
					      print(">> TCP/IP: Connected")
					      write_file("`nTCP/IP: Connected to IP[" ip "] : PORT[" port "]`n", general_log)
						  serial := ip ":" port
					   }
					} else {
					   write_file("`nTCP/IP: Could not define port as """ port """`n", general_log)
					   show_msg := true
					}
				  } else if print(">> TCP/IP: Without USB?") && (adb("connect " ip ":" port, 5) ~= "connected|already") {
				    print(">> TCP/IP: Yeah, connected")
					write_file("`nTCP/IP: Connected to IP[" ip "] : PORT[" port "] without a USB connection`n", general_log)
					with_usb := false
					serial := ip ":" port
				  } else {
				    print(">> TCP/IP: With USB")
					with_usb:=true
				    if !increased {
					   attemps++
					   increased:=true
					} else {
					   write_file("`nTCP/IP: Device not booted or unauthorized`n", general_log)
					   help(current "\images\dev_wir.png", "Could NOT establish wireless connection, insufficient permissions or invalid IP for the device.")
					   Process, Close, % basename(adb)
					}
				  }
			   }
		       result := adb("devices -l")
		   }
		   Loop, Parse, result, `n
           {
		        device_serial := get_serial(A_LoopField)
				if device_serial {
				   serial_n++
				   if !RegexMatch(A_LoopField, "model:\K\S+", name) {
				      if !RegexMatch(A_LoopField, "(device product|device):\K\S+", name)
					     name := "Device " serial_n
				   }
				   if get_serial(A_LoopField, true) {
				      connection := "WIFI"
				   } else {
				      connection := "USB"
				   }
				   devices.Insert({name: name, connection: connection, serial: device_serial})
				   if (serial && device_serial=serial) {
				      currentdevice := devices[devices.MaxIndex()]
				   }
				}
           }
		   if ((show_panel&&devices.MaxIndex())||(!currentdevice&&devices.MaxIndex()>1)) {
		       timed_msg_destroy()
		       Gui new4: Default 
		       Gui new4: -MinimizeBox +AlwaysOnTop
			   Gui new4: margin, %mx%, %my%
			   Gui new4: Font, s10, %style%
			   Gui new4: Add, Text, Y+0, Select a device:
			   Gui new4: Add, ListView, AltSubmit NoSortHdr -LV0x10 LV0x20 +Grid +LVS_FULLROWSELECT XS Y+10 hwndselect_device gselect_device,Device |Connection |Serial
			   LV_Delete()
			   Loop, % devices.MaxIndex()
			   {
			      LV_Add("", devices[A_Index].name, devices[A_Index].connection, devices[A_Index].serial)
			   }
			   Loop % LV_GetCount("Column")
                  LV_ModifyCol(A_Index, "AutoHdr Center")
			   HHDR := DllCall("SendMessage", "Ptr", select_device, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr") ; LVM_GETHEADER
            HeaderColors[HHDR] := {Txt: 0xFFFFFF, Bkg: 0x797e7f} ; BGR
            SubClassControl(select_device, "HeaderCustomDraw")
			   Gui new4: Show, AutoSize Center, Devices
			   WinSet, Redraw, , ahk_id %HHDR%
			   WinWaitClose, Devices
			   Gui new4: Destroy
		   } else if !devices.MaxIndex() {
		      continue
		   }
		   if !currentdevice {
		      currentdevice := devices[1]
		   }
		   serial := currentdevice.serial
		   exist_device=
         device_mode=
		   RegexMatch(result, "`am)^(\Q" serial "\E)[ `t]+\S+", result)
		   if (result ~= "\bfastboot\b") {
		      exist_device=true
			   device_mode=fastboot
		   } else {
		       if (result ~= "\bdevice\b") {
		          exist_device=true
				    device_mode=booted  
		       } else {
                  if (result ~= "\brecovery\b") {
		              exist_device=true
				        device_mode=recovery  
		          } else {
                     if (result ~= "\bsideload\b") {
		                 exist_device=true
				           device_mode=sideload   
		             } else {
                      if (result ~= "\bunauthorized\b") {
						       help(current "\images\dev_options.png", "A device was detected, but access is denied!`n`nPlease fix it manually:`nYou can try turning USB debugging off and on.")
				             break
		                } else {
                        if (result ~= "\boffline\b") {
                           help(current "\images\turn_on.png", "A device was detected, but it is inactive!`n`nPlease Turn On the Screen of your device to restore the connection.")
                           break
                        } else {
                           continue
                        }
						    }
		             }
		          }
		       }
		   }
		   if exist_device {
		      device_connection:=currentdevice.connection
		      if !(with_usb&&wireless_FORCE) {
			      with_usb ? print(">> TCP/IP: Skipped")
				  write_file("`nDefault device----> Name[" currentdevice.name "] : Connection[" currentdevice.connection "] : Mode[" device_mode "] : Serial[" currentdevice.serial "]`n", general_log)
				  if show_box
					 print(">> Device detected!")
				  if device_mode {
					 remember_mode := device_mode
				  }
				  break
			  }
		   }
       } else {
	      if show_panel
	         timed_msg_destroy()
	      if show_box {
		     print(">> Cant find any device")
		  }
		  if show_msg {
			  if wireless_IP {
		         MsgBox, 262144, HELP, % "HUH Can't connect TCP/IP: `n`nIP[" ip "] : PORT[" port "]"
			  } else {
			     MsgBox, 262144, HELP, HUH Can't detect your device
			  }
		  }
		  break
	   }
   }
   if exist_device {
      if (device_mode="fastboot")
         get_bootloader_env()
      return 1
   } else {
      return 0
   }
   new4GuiClose:
   if !show_panel&&!currentdevice {
      MsgBox, 262144, HELP, % "Double click the device you want"
   } else {
	  Gui new4: Destroy
   }
   return
   select_device:
   If (A_GuiEvent = "DoubleClick") && devices[A_EventInfo] {
	  currentdevice := devices[A_EventInfo]
	  Gui new4: Destroy
	  if show_panel
	     print(">> Device: " currentdevice.name)
   }
   return
}
delete_partition(part) {
   global general_log
   global serial
   global fastbootd
   if (serial && !check_active(serial))
      return 0
   if !fastbootd {
      MsgBox, 262144, HELP, You cant delete partitions from normal fastboot, only fastbootD
	  return 0
   }
   part := with_slot(part)
   if !is_real(part) {
      print(">> " part " partition does not exist!")
	  return 0
   }
   if is_logical(part) {
      print(">> Deleting " part "...")
      result := fastboot("delete-logical-partition " part " -s " serial)
   } else {
      print(">> No dynamic part: " part)
	  MsgBox, 262144, HELP, You can only delete Dynamic Partitions
	  return 0
   }
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
      MsgBox, 262144, ERROR, % result
	  return 0
   }
   return 1
   ; Possible evalaluation of errors coming soon
}
create_partition(part, size) {
   global super
   global general_log
   global serial
   global fastbootd
   if (serial && !check_active(serial))
      return 0
   if !fastbootd {
      MsgBox, 262144, HELP, You cant create partitions from normal fastboot, only fastbootD
	  return 0
   }
   if !super {
      print(">> No dynamic device")
	  MsgBox, 262144, HELP, You can only create partitions on devices with Dynamic Partitions
	  return 0
   }
   if !size
      return 0
   print(">> Creating " part "...")
   result := fastboot("create-logical-partition " part " " size " -s " serial)
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
      MsgBox, 262144, ERROR, % result
	  return 0
   }
   return 1
   ; Possible evalaluation of errors coming soon
}
to_bytes(size) {
   in := RegExReplace(size, "^(?:[0-9]+(?:[.][0-9]+)?)([a-zA-Z]+)?$", "$1")
   size := RegExReplace(size, "^([0-9]+([.][0-9]+)?)([a-zA-Z]+)?$", "$1")
   if !size
      return
   if (in="GB") {
      size := size * 1024**3
   } else if (in="MB") {
	  size := size * 1024**2
   } else if (in="KB") {
	  size := size * 1024
   } else if (in!="B") {
      return
   }
   size := Floor(size)
   if size is integer
   {
      return size
   } else {
      return
   }
}
install_manager() {
   global mx, my, style, installcontrol, install_files, all_formats, current, HeaderColors, formats
   Gui, 1:Submit, NoHide
   GuiControlGet, part, 1:, partition
   IniRead, zip_msg, % current "\configs.ini", GENERAL, zip_msg, 0
   if (part && part!="None") && (install_files[install_files.MaxIndex()].part!=part) {
      install_files[install_files.MaxIndex()].part := part
   }
   ext:=""
   if (all_formats=1) {
      ext := "*.*"
   } else if formats {
      if IsObject(formats) {
         for count, value in formats {
            ext ? ext .= ";" 
            ext .= "*." value
         }
      } else {
         ext := "*." formats
      }
   }
   (!ext) ? ext := "*.img;*.zip;*.apk"
   Gui 3: Default 
   Gui 3: +AlwaysOnTop
   Gui 3: margin, %mx%, %my%
   Gui 3: Font, s10, %style%
   Gui 3: Add, ListView, AltSubmit -ReadOnly hwndmanager NoSortHdr -LV0x10 LV0x20 Checked ginstallcontrol vinstallcontrol Y+0 w320 h200, |Partition|File to install
   LV_Delete()
   list := New LV_InCellEdit(manager)
   list.SetColumns(2)
   for index, file in install_files {
      LV_Add("", "", file.part, file.file)
      (file.install) ? LV_Modify(index, "Check")
   }
   LV_ModifyCol(1, "Center")
   Loop % LV_GetCount("Column")
      LV_ModifyCol(A_Index, "AutoHdr")
   HHDR := DllCall("SendMessage", "Ptr", manager, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr") ; LVM_GETHEADER
   HeaderColors[HHDR] := {Txt: 0xFFFFFF, Bkg: 0x797e7f} ; BGR
   SubClassControl(manager, "HeaderCustomDraw")
   Gui 3: show, AutoSize Center, Installation Manager
   WinSet, Redraw, , ahk_id %HHDR%
   WinWaitClose, Installation Manager
   Gui 3: Destroy
   installcontrol:
   If (list["Changed"]) {
       Row =
		 Column =
		 New =
       For I, O In list.Changed
         Row .= O.Row, Column .= O.Col, New .= O.Txt
		 if New {
          install_files[Row].part := New
          if (New="UPDATE FILE")
             install_files[Row].is_zip := false
		    if (install_files.MaxIndex()=Row)
		       GuiControl, 1:, partition, % New
          list.Remove("Changed")
		    LV_ModifyCol(2, "AutoHdr")
       } else {
		    MsgBox, 262144, HELP, You cant put an empty partition
			 list.Remove("Changed")
			 LV_Modify(Row, "Col2", install_files[Row].part)
			 return
		 }
   }
   If (A_GuiEvent == "I") {
        If (ErrorLevel == "C") {
          install_files[A_EventInfo].install := true
        } else If (ErrorLevel == "c") {
		    install_files[A_EventInfo].install := false
	    }
   }
   If (A_GuiEvent == "DoubleClick" && install_files.HasKey(A_EventInfo)) {
     Column := LV_SubItemHitTest(manager)
	  If (Column=3) {
	      Gui 3: -AlwaysOnTop
         FileSelectFile, file, 1,, Please select some IMG to Install, (%ext%)
         if file {
            install_files[A_EventInfo].file := file
            LV_Modify(A_EventInfo, "Col3", file)
            LV_ModifyCol(3, "AutoHdr")
            if !(install_files[A_EventInfo].part="UPDATE FILE") && (extname(file)="zip" || extname(file)="apk") {
               install_files[A_EventInfo].is_zip:=true
               install_files[A_EventInfo].part:="ZIP FILE"
               LV_Modify(A_EventInfo, "Col2", "ZIP FILE")
               LV_ModifyCol(2, "AutoHdr")
               if (install_files.MaxIndex()=A_EventInfo)
                  GuiControl, 1:, partition, ZIP FILE
               if (zip_msg!=1) {
                  MsgBox, 262144, HELP, The installation of ZIPs requires a Custom Recovery, so`nAll loaded ZIPs will be installed after the IMGs and not in load order
                  IniWrite, 1, % current "\configs.ini", GENERAL, zip_msg
               }
            }
	     }
		  Gui 3: +AlwaysOnTop
	  }
   }
   return
}
xiaomeme_test(img) {
   global current_anti
   global anti_notspam
   if !current_anti
      current_anti = 0
   if anti_notspam
      return 1
   path := dirname(img)
   name := basename(img)
   if FileExist(path "\anti_version.txt") {
      xiaomeme := true
	  anti := read_file(path "\anti_version.txt")
   } else If FileExist(path "\flash_all.bat") {
      xiaomeme := true
	  anti := RegExReplace(read_file(path "\flash_all.bat"), ".*CURRENT_ANTI_VER=([0-9]+).*", "$1", result)
	  if !result
	     anti =
   }
   anti := Trim(anti, "`n`r" A_Space "`t")
   if xiaomeme {
     if anti is integer
	 {
	    if (current_anti>anti) {
		   MsgBox, 262148, WARNING, % "Your Xiaomi device does not support this firmware (Anti Roll Back: " current_anti " > " anti ")`n`nRISK:    KILL YOUR DEVICE`nFILE:     " name "`n`nDo you really want to continue?"
	       IfMsgBox Yes
		   {
		     anti_notspam := true
		     return 1
		   } else {
		     return 0
		   }
		} else {
		   return 1
		}
	 } else {
	    MsgBox, 262148, WARNING, % "Xiaomi firmware was detected, but the Anti Roll Back number could not be obtained`n`nRISK:    Possibly kill your device`nFILE:     " name "`n`nDo you really want to continue?"
	    IfMsgBox Yes
		{
		  anti_notspam := true
		  return 1
		} else {
		  return 0
		}
	 }
   } else {
      return 1
   }
}
with_slot(part) {
   global current_slot
   GuiControlGet, default_slot, 1:, default_slot
   default_slot := Trim(default_slot, "`n" A_Space "`t")
   if !(part ~= "_(a|b)$") {
      if (default_slot="disabled") {
         part := part
      } else if (default_slot="a") || (default_slot="b") {
	     if is_real(part "_" default_slot)
            part := part "_" default_slot
      } else if default_slot && (default_slot!="auto") && is_real(part default_slot) {
         part := part default_slot
      } else if current_slot && is_real(part current_slot) {
	     part := part current_slot
      }
   }
   return part
}
install_img(img, part, extra := "", extra2 := "") {
   global force_install
   global general_log
   global serial
   if (serial && !check_active(serial))
      return 0
   if (part="UPDATE FILE") {
      mode := "update " extra2 " """ img """"
   } else {
     part := with_slot(part)
	  mode := "flash " extra2 part " " """" img """"
	  if !is_real(part) {
         print(">> " part " partition does not exist!")
	     return 0
      }
	  if !xiaomeme_test(img) {
	     print(">> Aborted: Anti Roll Back")
	     return 0
	  }
	  if (force_install!=1) {
         If !check_free_space(img, part) {
            return 0
         }
      }
   }
   print(">> Installing " part ": " basename(img))
   result := fastboot("--skip-reboot " extra " " mode " -s " serial)
   ; Evaluation of common erros
   if InStr(result, "error partition size") {
      write_file(result, general_log)
      print(">> Invalid partition size!")
      return 0
   } else if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
      MsgBox, 262144, ERROR, % result
	  return 0
   }
   return 1
}
ensure_fastboot() { 
   global device_mode
   global remember_mode
   global serial
   global default_mode
   global general_log
   Gui, 1:Submit, NoHide
   if (serial && !check_active(serial))
      return 0
   if (device_mode!="fastboot") {
      /*
      if InStr(adb_shell("getprop | grep manufacturer"), "samsung") {
	     GuiControl, 1:Choose, default_mode, 2
	   }
      */
      print(">> Rebooting in fastboot...")
      (default_mode=1) ? mode:="bootloader" : mode:="fastboot"
      (ensure_shell||InStr(result:=adb_serial("reboot " . mode), "refused")) ? result .= adb_shell("reboot " . mode)
	   print(">> Waiting device")
   }
   find_device(20)
   if (device_mode="fastboot") {
      return 1
   } else {
      write_file(result, general_log)
      print(">> Oops! Cant reboot in fastboot")
	   MsgBox, 262144, ERROR, Cant reboot in fastboot
      return 0
   }
}
update_drivers() {
   global current
   global winver
   global drivers
   global nospam
   global general_log
   global exitcode
   IniRead, drivers, % current "\configs.ini", GENERAL, drivers, 0
   if (drivers=1)
      return
   if nospam
      return
   Loop, %current%/drivers/windows%winver%/*.inf {
      if !pass {
         MsgBox, 262148, Drivers, Drivers for Windows %winver% were detected, do you want to install them?
	     IfMsgBox Yes
		 {
            pass := true
			If A_Is64bitOS && FileExist(A_LoopFileDir "/64bits.exe") {
			   result := run_cmd("""" A_LoopFileDir "/64bits.exe" """" " 2>&1")
			   break
			} else if !A_Is64bitOS && FileExist(A_LoopFileDir "/32bits.exe") {
			   result := run_cmd("""" A_LoopFileDir "/32bits.exe" """" " 2>&1")
			   break
			}
			result .= run_cmd("pnputil -i -a " """" A_LoopFileLongPath """" " 2>&1")
	     } else {
		    nospam := true
			IniWrite, 1, % current "\configs.ini", GENERAL, drivers
	        break
	     }
	  } else {
	     result .= run_cmd("pnputil -i -a " """" A_LoopFileLongPath """" " 2>&1")
	  }
   }
   if !result {
      Loop, %current%/drivers/*.inf {
	     if !pass {
            MsgBox, 262148, Drivers, Drivers were detected, do you want to install them?
	        IfMsgBox Yes
			{
               pass := true
			   If A_Is64bitOS && FileExist(A_LoopFileDir "/64bits.exe") {
			      result := run_cmd("""" A_LoopFileDir "/64bits.exe" """" " 2>&1")
			      break
			   } else if !A_Is64bitOS && FileExist(A_LoopFileDir "/32bits.exe") {
			      result := run_cmd("""" A_LoopFileDir "/32bits.exe" """" " 2>&1")
			      break
			   }
			   result .= run_cmd("pnputil -i -a " """" A_LoopFileLongPath """" " 2>&1")
	        } else {
			   nospam := true
			   IniWrite, 1, % current "\configs.ini", GENERAL, drivers
	           break
			}
	     } else {
	        result .= run_cmd("pnputil -i -a " """" A_LoopFileLongPath """" " 2>&1")
	     }
      }
   }
   if pass {
     if result
        write_file(result, general_log)
     if (exitcode<=0)||(result ~= "i)\berror|failed\b") {
	    write_file("`nDriver installation ended with:" exitcode " `n", general_log)
	    print(">> Cant install drivers!")
		MsgBox, 262144, ERROR, The drivers were not installed correctly
	 } else {
	    IniWrite, 1, % current "\configs.ini", GENERAL, drivers
	    print(">> Updated drivers")
	 }
   }
}
format_data() {
   global device_mode
   global exist_device
   global serial
   global fastbootd
   if (serial && !check_active(serial))
      return 0
   print(">> Wiping userdata...")
   if (device_mode="fastboot") {
	   if fastbootd {
		  result := fastboot("-w" " -s " serial)
		  if (result ~= "i)\berror|failed\b") {
			 result := fastboot("erase userdata" " -s " serial)
		  }
	   } else {
		  result := fastboot("erase userdata" " -s " serial)
	   }
   } else {
      run_binary("twrp") && twrp := true
	  if twrp {
	     result := adb_shell("twrp format data || echo ERROR")
	  } else {
	     result := adb_shell("rm -rf /data/* || echo ERROR")
	  }
   }
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
      MsgBox, 262144, ERROR, % "A problem formatting the device storage!"
	  return 0
   }
   return 1
}
push(file, dest) {
   global exist_device
   global device_mode
   global general_log
   global ensure_recovery
   global serial
   if (serial && !check_active(serial))
      return 0
   if !exist_device
      return 0
   if !FileExist(file) {
      MsgBox, 262144, ERROR, % "Cant find " basename(file)
      return 0
   }
   if (device_mode="fastboot") {
      gosub reboot_recovery
	  adb_shell("setprop sys.usb.config mtp,adb")
      adb_shell("setprop sys.usb.ffs.mtp.ready 1")
      ensure_shell()
   }
   result := adb_shell("[ ! -d " """" dest """" " ] && mkdir -p " """" dest """")
   print(">> Sending " basename(file) "...")
   ensure_shell()
   Sleep, 1000
   ensure_shell()
   result .= adb_serial("push " """" file """" " " """" dest """")
   result .= adb_shell("[ ! -f " """" dest "/" basename(file) """" " ] && echo " """" "ERROR: Cant find " basename(file) """")
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
      MsgBox, 262144, ERROR, % "Unable to load " basename(file) " on the device"
	  return 0
   }
   return 1
}
setup_busybox(tmp, dest := "") {
   global busybox
   global general_log
   global busybox_work
   busybox_work := ""
   if !push(busybox, tmp)
      return 0
   print(">> Starting " basename(busybox) "...")
   result .= adb_shell("[ -f " """" tmp "/" basename(busybox) """" " ] && chmod 777 " tmp "/" basename(busybox) " || echo " """" "ERROR: Cant find " basename(busybox) """")
   if dest {
      result .= adb_shell("rm -rf " dest)
      result .= adb_shell("mkdir -p " dest)
      result .= adb_shell("""" tmp "/" basename(busybox) """" " --install -s " dest)
      result .= adb_shell("[ ! -e " """" dest "/unzip" """" " ] && echo " """" "ERROR: Cant setup " basename(busybox) """")
   } else {
      result .= adb_shell("""" tmp "/" basename(busybox) """" " unzip --help || echo " """" "ERROR: Cant run" basename(busybox) """")
   }
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
	  MsgBox, 262144, ERROR, % "Cant setup " basename(busybox)
	  return 0
   }
   print(">> Success")
   busybox_work := tmp "/" basename(busybox)
   return 1
}
busybox(action) {
   global busybox_work
   if !busybox_work
      return 0
   result := adb_shell("""" busybox_work """" " " action)
   return result
}
exist_file(file) {
   ;Files, Folders, symlinks, ...
   global general_log
   result := adb_shell("[ -e " """" file """" " ] && echo File exist")
   if InStr(result, "File exist") {
      return 1
   } else {
      write_file(result, general_log)
      return 0
   }
}
exist_dir(dir) {
   global general_log
   result := adb_shell("[ -d " """" dir """" " ] && echo Dir exist")
   if InStr(result, "Dir exist") {
      return 1
   } else {
      write_file(result, general_log)
      return 0
   }
}
delete_file(file) {
   global general_log
   result .= adb_shell("rm -f " """" file """" " && echo Success")
   if InStr(result, "Success") {
      return 1
   } else {
      write_file(result, general_log)
      return 0
   }
}
delete_dir(dir) {
   global general_log
   result .= adb_shell("rm -rf " """" dir """" " && echo Success")
   if InStr(result, "Success") {
      return 1
   } else {
      write_file(result, general_log)
      return 0
   }
}
create_dir(dir) {
   global general_log
   result .= adb_shell("mkdir -p " """" dir """" " && echo Success")
   if InStr(result, "Success") {
      return 1
   } else {
      write_file(result, general_log)
      return 0
   }
}
copy(any, to) {
   global general_log
   if !exist_file(any) {
	   MsgBox, 262144, ERROR, % "Cant find " any " on the device"
       return 0
   }
   result .= adb_shell("cp -rf " """" any """" " " """" to """" " && echo Success")
   if InStr(result, "Success") {
      return 1
   } else {
      MsgBox, 262144, ERROR, % "Cant copy " any " in " to
      write_file(result, general_log)
      return 0
   }
}
run_binary(binary, action := ""){
    global exist_device
    global device_mode
	global serial
	global general_log
	if (serial && !check_active(serial))
      return 0
	if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The run_binary function is not supported from fastboot
	   return 0
	}
    result := adb_shell("[ -e " """" "$(command -v " binary ")" """" " ] && echo " Format("{:U}",binary) " command support")
	write_file(result, general_log)
	if InStr(result, Format("{:U}",binary) " command") {
	   if !action
          return 1
	   work := adb_shell("echo $(command -v " binary ")")
	} else {
	   if action
	      MsgBox, 262144, ERROR, % binary " command is not supported by device"
	   return 0
	}
   result .= adb_shell("""" work """" " " action)
   return result  
}
ensure_tmp(needexec := ""){
   global general_log
   global device_mode
   global TMP
   if needexec {
      if (TMP ~= "^/sdcard") {
	     result .= "`nUnable to execute scripts in """ TMP """, using ""/tmp""`n"
         TMP := ""
      }
   } else if (device_mode="booted") {
      if !(TMP ~= "^/sdcard") {
	     if TMP {
		    result .= "`nUnable to pass files to """ TMP """ because the device is booted, using ""/sdcard/tmp""`n"
		 }
         TMP := "/sdcard/tmp"
      }
   }
   if !exist_dir(TMP) {
      if TMP {
	      create_dir(TMP)
	   }
	   if !exist_dir(TMP) {
	      if TMP {
		     result .= "`nCANT CREATE """ TMP """, using ""/tmp""`n"
		  }
		  TMP := "/tmp"
		  create_dir(TMP)
		  if !exist_dir(TMP) {
		     result .= "`n""" TMP """ UNSUPPORTED, using ""/dev/tmp__""`n"
		     TMP := "/dev/tmp__"
		     create_dir(TMP)
	      }
	   }
	   if !exist_dir(TMP) {
		  result .= "`n" TMP " UNSUPPORTED`n"
        TMP := ""
		  write_file(result, general_log)
		  MsgBox, 262144, ERROR, Cannot create a temp directory on the device
		  return
	   }
   }
   write_file(result, general_log)
   return TMP
}
flash_zip(zip) {
   global exist_device
   global device_mode
   global general_log
   global ensure_recovery
   global serial
   if (serial && !check_active(serial))
      return 0
   if !exist_device
      return 0
   if (ensure_recovery=1 && device_mode!="recovery")||(device_mode="fastboot") {
      gosub reboot_recovery
	  adb_shell("setprop sys.usb.config mtp,adb")
      adb_shell("setprop sys.usb.ffs.mtp.ready 1")
      ensure_shell()
   }
   TMP := ensure_tmp(true)
   if !TMP
      return 0
   if !exist_file(zip) {
      MsgBox, 262144, ERROR, % "Cant find """ zip """ on the device"
      return 0
   }
   run_binary("twrp") && twrp := true
   run_binary("unzip") && unzip := true
   print(">> Installing " """" ubasename(zip) """")
   print(">> Please wait...")
   if twrp && unzip {
      result .= adb_shell("twrp install " """" zip """")
   } else {
      if !unzip && !setup_busybox(TMP)
	     return 0
      result .= adb_shell("rm -rf " TMP "/META-INF")
	  print(">> Loading environment...")
	  if unzip {
         result .= adb_shell("unzip -qo " """" zip """" " META-INF/com/google/android/update-binary -d " TMP)
	  } else {
	     result .= busybox("unzip -qo " """" zip """" " META-INF/com/google/android/update-binary -d " TMP)
      }
      result .= adb_shell("[ -f " TMP "/META-INF/com/google/android/update-binary ] && chmod 777 " TMP "/META-INF/com/google/android/update-binary || echo ERROR: Cant extract update-binary")
	  if (result ~= "i)\berror\b") {
	     write_file(result, general_log)
	     MsgBox, 262144, ERROR, % "Cant execute " ubasename(zip)
	     return 0
	  }
	  result .= "-------------" ubasename(zip) "-------------`n" 
	  try := adb_shell("""" TMP "/META-INF/com/google/android/update-binary" """" " 3 3 " """" zip """")
	  if !(try ~= "inaccessible|No such file") {
	     result .= try
      } else {
	     result .= adb_shell("sh " """" TMP "/META-INF/com/google/android/update-binary" """" " 3 3 " """" zip """")
	  }
	  result .= "------------------------------------------`n"
   }
   write_file(result, general_log)
   return 1
}
flash_zip_push(zip) {
   global exist_device
   global device_mode
   global general_log
   global ensure_recovery
   global serial
   if (serial && !check_active(serial))
      return 0
   if !exist_device
      return 0
   if (ensure_recovery=1 && device_mode!="recovery")||(device_mode="fastboot") {
      gosub reboot_recovery
	  adb_shell("setprop sys.usb.config mtp,adb")
      adb_shell("setprop sys.usb.ffs.mtp.ready 1")
      ensure_shell()
   }
   TMP := ensure_tmp()
   if !TMP
      return 0
   if !push(zip, TMP)
      return 0
   if !flash_zip(TMP "/" basename(zip)) {
      return 0
   } else {
      delete_file(TMP "/" basename(zip))
	  return 1
   }
}
read_xml(url, time:=3000, hide:="") {
   global general_log
   ComObjError(false)
   get := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   try {
      time ? get.SetTimeouts(time, time, time, time)
      get.Open("GET", url, false)
      get.Send()
      status := get.status
      if (status != 200) {
         if hide 
            url := ubasename(url)
         if !status
            status := "No internet connection"
         result := "`nUnable to read WEB content: """ url """, EXIT:" status "`n"
         write_file(result, general_log)
         return
      }
      result := get.responseText
      get.Quit
      return result
   } catch e {
      result := "`nError reading WEB content: """ e.message """`n"
      write_file(result, general_log)
      return
   }
}
web_config(url, time:=false, hide:="") {
   return load_config(read_xml(url,time,hide),,, FD_CURRENT)
}
get_hash(file, type){
   global general_log
   if (type ~= "\bMD2|MD4|MD5\b") {
		checklen = 32
   } else if (type = "SHA1") {
		checklen = 40
   } else if (type = "SHA256") {
		checklen = 64
   } else if (type = "SHA384") {
		checklen = 96
   } else if (type = "SHA512") {
		checklen = 128
   } else {
	  write_file("`nUnsupported hash type: " type "`n", general_log)
	  return
   }
   try := run_cmd("""" dirname(comspec) "\certutil.exe"" -hashfile """ file """ " type)
   RegExMatch(try, "\b[A-Fa-f0-9]{" checklen "}\b", hash)
   if !hash {
      write_file("`nCant get hash of: " file "`n", general_log)
	  return
   }
   return hash
}
check_bin(force := "") {
   global current
   global tools
   global extras
   global general_log
   xml:=read_xml("https://raw.githubusercontent.com/BlassGO/auto_img_request/main/bin_hash.txt",, true)
   if !xml {
      xml=
	  (
	  
	   [tools\fastboot.exe]
      SHA256 b19c076410f644525569aa066cfca99d3d0647c5f41898ee178c906222648fe2
      SHA256 2a18a8b190dda066090544807c518f5efbe876145402113b02ff486189bbd266 #platform-tools 33.0.0

      [tools\adb.exe]
      SHA256 fd488a4e13d4c71acce69e209164398a056fba5a559b7f00c1351390604e5b98
      SHA256 2e8a440a90ff1b15c8cf93eaf47fbb8f95fc0d14e9fa665dd9f4a2596387bbbf #platform-tools 33.0.0

      [tools\AdbWinApi.dll]
      SHA256 d60103a5e99bc9888f786ee916f5d6e45493c3247972cb053833803de7e95cf9 #platform-tools 33.0.0

      [tools\AdbWinUsbApi.dll]
      SHA256 25207c506d29c4e8dceb61b4bd50e8669ba26012988a43fbf26a890b1e60fc97 #platform-tools 33.0.0

      [extras\busybox]
      SHA256 ccdb7753cb2f065ba1ba9a83673073950fdac7a5744741d0f221b65d9fa754d3
	  
	  )
   }
   if force
      IniDelete, % current "\configs.ini", ALLOWED
   _pos=1
   while _pos := RegExMatch(xml, "((\[)((?<!(\])).)+)([^s]|.)+?(?=\[|(\r*\n$))", _section, _pos + StrLen(_section))
   {
	  RegExMatch(_section, "((\[)\K.+(?=\]))", _file)
	  RegExMatch(_section, "(\[\Q" _file "\E\]\K([^s]|.)+)", _with)
	  if FileExist(current "\" _file) {
	     currenthash=
		 passed:=false
	     IniRead, hash, % current "\configs.ini", ALLOWED, % _file, % A_Space
		 IniRead, hashtype, % current "\configs.ini", ALLOWED, % _file "_type", % A_Space
		 if hash && hashtype 
	        currenthash:=get_hash(current "\" _file, hashtype)
		 if currenthash && (currenthash=hash){
		   passed:=true
		 } else {
			 Loop, parse, _with, `n, `r
			 {
				if A_LoopField {
					hashtype=
					checklen=
					hash=
					if (A_LoopField ~= "\bMD2|MD4|MD5\b") {
						RegExMatch(A_LoopField, "\bMD2|MD4|MD5\b", hashtype)
						checklen = 32
					} else if (A_LoopField ~= "\bSHA1\b") {
						hashtype = SHA1
						checklen = 40
					} else if (A_LoopField ~= "\bSHA256\b") {
						hashtype = SHA256
						checklen = 64
					} else if (A_LoopField ~= "\bSHA384\b") {
						hashtype = SHA384
						checklen = 96
					} else if (A_LoopField ~= "\bSHA512\b") {
						hashtype = SHA512
						checklen = 128
					} else {
					   write_file("`nCant get a valid hash type for: " _file "`n", general_log)
					   continue
					}
					RegExMatch(A_LoopField, "\b[A-Fa-f0-9]{" checklen "}\b", hash)
					if !hash {
					   write_file("`nNo valid hash found for: " _file " : " hashtype "`n", general_log)
					   continue
					} else {
					   currenthash:=get_hash(current "\" _file, hashtype)
					   if (hash=currenthash) {
					      passed:=true
					      break
					   }
					}
				}
			 }
		 }
		 if passed {
		    IniWrite, % currenthash, % current "\configs.ini", ALLOWED, % _file
		    IniWrite, % hashtype, % current "\configs.ini", ALLOWED, % _file "_type"
			write_file("`n" _file " is authorized...`n", general_log)
		 } else {
			write_file("`n" _file " is NOT authorized, waiting for the user...`n", general_log)
			MsgBox, 262148, Authorized tools, % " WARNING! The following file was replaced by an unauthorized version:`n`n " current "\" _file "`n`n Do you want to allow it?"
			IfMsgBox Yes
	        {
	            IniWrite, % currenthash, % current "\configs.ini", ALLOWED, % _file
				IniWrite, % hashtype, % current "\configs.ini", ALLOWED, % _file "_type"
				continue
	        }
			MsgBox, 262144, Authorized tools, % " Okay, removing--->" _file "`n`n Please download it from an official site"
			write_file("`nRemoving " _file "...`n", general_log)
			FileDelete, % current "\" _file
			gosub finish
		 }
	  }
   }
   return 1
}
download(url, to, option:="") {
   global secure_user_info
   global general_log
   global HERE
   global TOOL
   global current
   GetFullPathName(to) ? to := GetFullPathName(to)
   if (to==current "\configs.ini") {
      MsgBox, 262144, Download Service, % " Attempting to replace:`n`n " to "`n`n This action is not allowed for your security"
      return 0
   }
   updating_script=
   (
   :destroy
   del "%A_ScriptFullPath%"
   if exist "%A_ScriptFullPath%" goto destroy
   move "%to%" "%A_ScriptFullPath%"
   `(goto`) 2>nul & del "`%~f0" & cmd /c start "%A_ScriptFullPath%" "%A_ScriptFullPath%"
   )
   if (secure_user_info && !(to ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
      MsgBox, 262148, Download Service, % " Attempting to download a file outside of common paths:`n`n " to "`n`n Do you want to allow it?"
	  IfMsgBox No
	  {
	     return 0
	  }
   }
   if (option ~= "\bMD2|MD4|MD5\b") {
        RegExMatch(option, "\bMD2|MD4|MD5\b", hashtype)
		checklen = 32
   } else if (option ~= "\bSHA1\b") {
        hashtype = SHA1
		checklen = 40
   } else if (option ~= "\bSHA256\b") {
        hashtype = SHA256
		checklen = 64
   } else if (option ~= "\bSHA384\b") {
        hashtype = SHA384
		checklen = 96
   } else if (option ~= "\bSHA512\b") {
        hashtype = SHA512
		checklen = 128
   }
   if (option ~= "\bupdate\b") {
      update=true
   }
   if (option ~= "\bforce\b") {
      force=true
   }
   if hashtype {
      if update {
		 RegExMatch(read_xml("https://raw.githubusercontent.com/BlassGO/auto_img_request/main/hash.txt",, true), "\b[A-Fa-f0-9]{" checklen "}\b", hash)
		 if !force && (hash=get_hash(A_ScriptFullPath,hashtype)) {
			write_file("`n" A_ScriptName " already updated, skipping...`n", general_log)
			return 1
	     }
	  } else {
         RegExMatch(option, "\b[A-Fa-f0-9]{" checklen "}\b", hash)
	  }
	  if !hash {
	     MsgBox, 262144, ERROR, % "No valid hash found for: " hashtype
		 return 0
	  }
   }
   bytes := HttpQueryInfo(url, 5)
   if bytes is not integer
   {
	  write_file("`n" wbasename(to) " download ended with: " bytes "`n", general_log)
      MsgBox, 262144, ERROR, % "Oops! no response from download server, try again later"
	  return 0
   }
   if FileExist(to) {
      FileGetSize, currentbytes, % to
      if !force && (bytes=currentbytes) {
	     write_file("`n" basename(to) " already has " bytes " bytes, skipping...`n", general_log)
	     if hash {
		    if (hash=get_hash(to,hashtype)) {
			   write_file("`n" basename(to) " passed " hashtype " hash check, skipping...`n", general_log)
			   if update {
				  FileDelete, % current "\killmeplz.bat"
				  if FileExist(current "\killmeplz.bat") {
				     MsgBox, 262144, ERROR, % "Anomaly was detected, please update the tool manually from an official site"
					 return 0
				  } else {
					 FileAppend, % updating_script, % current "\killmeplz.bat"
					 Run, "%current%\killmeplz.bat", , Hide
					 gosub finish
				  }
			   }
			   return 1
			} else {
			   write_file("`n" basename(to) " DID NOT pass " hashtype " hash check, removing...`n", general_log)
			   FileDelete, % to
			}
		 } else {
		    return 1
		 }
      } else {
	     FileDelete, % to
	  }
   }
   disable_bar()
   enable_bar()
   print(">> Downloading: """ wbasename(to)"""")
   SetTimer, progress, 250
   UrlDownloadToFile, % url, % to
   result := ErrorLevel
   SetTimer, progress, Off
   if result {
      MsgBox, 262144, ERROR, % " Unable to download content: `n " url
	  result:=0
   } else {
      FileGetSize, currentbytes, % to
      if (bytes!=currentbytes) {
		 write_file("`n" basename(to) " has " currentbytes " of " bytes ", removing...`n", general_log)
		 FileDelete, % to
		 MsgBox, 262144, ERROR, % """" wbasename(to) """ is corrupted (and was removed), please try again later "
		 result:=0
	  } else if hash {
	     if (hash=get_hash(to,hashtype)) {
			write_file("`n" basename(to) " passed " hashtype " hash check`n", general_log)
			if update {
			   FileDelete, % current "\killmeplz.bat"
			   if FileExist(current "\killmeplz.bat") {
			      MsgBox, 262144, ERROR, % "Anomaly was detected, please update the tool manually from an official site"
				  result:=0
			   } else {
				  FileAppend, % updating_script, % current "\killmeplz.bat"
				  Run, "%current%\killmeplz.bat", , Hide
				  gosub finish
			   }
			} else {
			   result:=1
			}
		 } else {
			write_file("`n" basename(to) " DID NOT pass " hashtype " hash check, removing...`n", general_log)
			FileDelete, % to
			MsgBox, 262144, ERROR, % """" wbasename(to) """ did not pass the specified " hashtype " check and was removed"
			result:=0
	     }
      } else {
		 result:=1
	  }
   }
   check_bin()
   disable_bar()
   return result
   progress:
   FileGetSize, currentbytes, % to
   If total := Round(currentbytes/bytes*100) {
      GuiControl, 1:, install_bar, % total
   }
   return
}
boot(img) {
   global exist_device
   global device_mode
   global general_log
   global serial
   if (serial && !check_active(serial))
      return 0
   if !exist_device
      return 0
   if !ensure_fastboot()
	  return 0
   if !FileExist(img) {
      unexpected := "Cant find " img
      return 0
   }
   print(">> Booting " basename(img))
   result := fastboot("boot " """" img """" " -s " serial)
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
	  print(">> Cant boot " basename(img))
	  unexpected := "Some problem booting " basename(img)
	  return 0
   }
   adb_shell("setprop sys.usb.config mtp,adb")
   adb_shell("setprop sys.usb.ffs.mtp.ready 1")
   ensure_shell()
   return 1
}
update(img, dest, nofind := "") {
    global general_log
	global exist_device
    global device_mode
	global serial
	if (serial && !check_active(serial))
       return 0
	if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The update function is not supported from fastboot
	   return 0
	}
	run_binary("dd") && dd := true
	run_binary("cat") && cat := true
	if !dd && !cat {
	   MsgBox, 262144, ERROR, update: No available actions found on the device
	   return 0 
	}
    if !exist_file(img) {
	   MsgBox, 262144, ERROR, % "Cant find " img " on the device"
       return 0
	}
	if !nofind {
		dest := find_block(dest)
		if !dest {
		  print(">> Cant find dest partition")
		  return 0
		} 
	} else if !exist_file(dest) {
	   print(">> Invalid dest partition: " dest)
	   return 0
	}
	if dd {
	   result .= run_binary("dd", "if=" """" img """" " of=" """" dest """" " && echo Success with dd")
	}
	if cat && !InStr(result, "Success") {
	   result .= run_binary("cat", """" img """" " > " """" dest """" " && echo Success with cat")
	}
	if !InStr(result, "Success") {
	   write_file(result, general_log)
	   print(">> Cant update " ubasename(img))
       MsgBox, 262144, ERROR, % " Some problem updating " ubasename(img) " in " dest
	   return 0
	}
	write_file(result, general_log)
	return 1
}
update_push(img, dest, nofind := "") {
	TMP := ensure_tmp()
	if !TMP
	   return 0
    if !push(img, TMP)
       return 0
	if update(TMP "/" basename(img), dest, nofind) {
	   if exist_file(TMP "/" basename(img))
	      delete_file(TMP "/" basename(img))
	   return 1
	} else {
	   return 0
	}
}
get_cmdline(prop) {
   run_binary("cat") && cat := true
   if !cat {
      MsgBox, 262144, ERROR, get_cmdline: cat command not supported on device
	  return
   }
   get := RegExReplace(adb_shell("cat /proc/cmdline 2>/dev/null"), "(?:^\h*|.*\h+)\Q" prop "=\E(\S+).*", "$1", result)
   if !result {
      get := RegExReplace(adb_shell("cat /proc/bootconfig 2>/dev/null"), "(?:^\h*|.*\R\h*)\Q" prop "\E\h*=\h*(.*?)(?:\R|$).*", "$1", result)
   }
   if result {
      get:=Trim(get, A_Space "`t")
   } else {
      get:=""
   }
   return get
}
get_slot() {
   global exist_device
   global device_mode
   global serial
   if (serial && !check_active(serial))
      return
   if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The get_slot function is not supported from fastboot
	   return
	}
   run_binary("getprop") && getprop := true
   run_binary("cat") && cat := true
   if cat {
      slot := get_cmdline("androidboot.slot_suffix")
      if !slot
         slot := get_cmdline("androidboot.slot")
   }
   if getprop && !slot {
      slot := adb_shell("getprop ro.boot.slot_suffix")
   }
   slot := Trim(slot, "`n`r" A_Space "`t")
   if slot && !InStr(slot, "_") {
      slot := "_" slot
   }
   return slot
}
find_block(name) {
   global exist_device
   global device_mode
   global serial
   global general_log
   if (serial && !check_active(serial))
      return
   if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The find_block function is not supported from fastboot
	   return
	}
   run_binary("find") && find := true
   slot := get_slot()
   if find {
	  try := adb_shell("if [ -e ""$(command -v head)"" ]; then part=$((find /dev/block \( -type b -o -type c -o -type l \) -iname " name " -o -iname " name slot " | head -n1) 2>/dev/null); elif [ -e ""$(command -v sed)"" ]; then part=$((find /dev/block \( -type b -o -type c -o -type l \) -iname " name " -o -iname " name slot " | sed -n ""1p;q"") 2>/dev/null); fi; [ -e ""$(command -v readlink)"" ] && echo $(readlink -f ""$part"") || echo $part", "", true)
	  try := Trim(try, "`n`r" A_Space "`t")
	  if exist_file(try) {
	     block := try
	  } else {
	     MsgBox, 262144, ERROR, % "Cant find " name " partition"
	  }
   } else {
      MsgBox, 262144, ERROR, find_block: find command not supported on device
	  return
   }
   return block
}
get_twrp_ramdisk(ramdisk) {
   global exist_device
   global device_mode
   global serial
   global general_log
   if (serial && !check_active(serial))
      return 0
   if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The get_twrp_ramdisk function is not supported from fastboot
	   return 0
   }
   run_binary("cpio") && cpio := true
   if !cpio {
	   MsgBox, 262144, ERROR, get_twrp_ramdisk: No available actions found on the device: cpio
	   return 0 
   }
   if !exist_file("/ramdisk-files.txt") {
      MsgBox, 262144, ERROR, Your current Recovery does not support building ramdisk A/B
	  return 0
   }
   result := run_binary("cpio", "-H newc -o < /ramdisk-files.txt > " """" ramdisk """")
   write_file(result, general_log)
   return 1
   ; Possible evalaluation of errors coming soon
}
remove_magisk(dir) {
   global exist_device
   global device_mode
   global serial
   global general_log
   global current
   if (serial && !check_active(serial))
      return 0
   if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The remove_magisk function is not supported from fastboot
	   return 0
   }
   run_binary("magiskboot") && magiskboot := true
   run_binary("cat") && cat := true
   if !magiskboot {
	   MsgBox, 262144, ERROR, Your current Recovery does not support kernel patching: magiskboot
	   return 0 
   }
   if !exist_file(dir "/kernel") {
	   MsgBox, 262144, ERROR, % "Cant find the kernel in " dir
       return 0
   }
   TMP := dir
   format .= decompress(TMP "/kernel", TMP "/kernel_")
   if format {
      result .= "Kernel with compression: " format " n"
   } else {
	  result .= adb_shell("cp -f " TMP "/kernel" " " TMP "/kernel_")
   }
   delete_file(TMP "/kernel")
   if !exist_file(TMP "/kernel_") {
       write_file(result, general_log)
	   MsgBox, 262144, ERROR, % "remove_magisk: Cant unpack the kernel"
       return 0
   }
   result .= adb_shell("cd " TMP " && magiskboot split kernel_")
   result .= adb_shell("cd " TMP " && magiskboot hexpatch kernel_ 77616E745F696E697472616D6673 736B69705F696E697472616D6673")
   if cat && exist_file(TMP "/header") {
      header := adb_shell("cat " TMP "/header" " || echo CANT READ")
	  if !InStr(header, "CANT READ") {
		 cmdline := RegExReplace(header, "(?:^|.*\R)cmdline=(.+?(?=\R)).*", "$1")
	  }
   }
   if cmdline && InStr(cmdline, "skip_override") {
	  Loop, parse, cmdline, %A_Space%
      {
	     if A_LoopField && !InStr(A_LoopField, "skip_override") {
		    newline .= A_LoopField " "
		 }
      }
	  header := RegExReplace(header, "cmdline=(.+?(?=\R))", "cmdline=" newline)
	  result .= "NEW HEADER: `n" header "`n"
	  FileDelete, % current "\newheader"
	  if !write_file(header, current "\newheader")
	     return 0
	  if !push(current "\newheader", TMP) {
	     write_file(result, general_log)
         return 0
	  }
	  FileDelete, % current "\newheader"
	  delete_file(TMP "/header")
	  result .= adb_shell("cp -f " TMP "/newheader" " " TMP "/header")
	  if !exist_file(TMP "/header") {
	     MsgBox, 262144, ERROR, % "remove_magisk: Cant generate new header"
	     write_file(result, general_log)
		 return 0
	  }
   }
   if format {
	  if !recompress(TMP "/kernel_", format, TMP "/kernel")
	     return 0
   } else {
	  result .= adb_shell("cp -f " TMP "/kernel_" " " TMP "/kernel")
   }
   if !exist_file(TMP "/kernel") {
      MsgBox, 262144, ERROR, % "remove_magisk: Cant generate new kernel"
	  write_file(result, general_log)
      return 0
   }
   write_file(result, general_log)
   return 1
}
update_ramdisk(ramdisk, part := ""){
   global exist_device
   global device_mode
   global serial
   global general_log
   if (serial && !check_active(serial))
      return 0
   if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The update_ramdisk function is not supported from fastboot
	   return 0
   }
   run_binary("magiskboot") && magiskboot := true
   if !magiskboot {
	   MsgBox, 262144, ERROR, Your current Recovery does not support boot.img building: magiskboot
	   return 0 
   }
   if !exist_file(ramdisk) {
	   MsgBox, 262144, ERROR, % "Cant find " ramdisk " on the device"
       return 0
   }
   TMP := ensure_tmp()
   if !TMP
	  return 0
   TMP := TMP "/update_0001"
   delete_dir(TMP)
   if !create_dir(TMP) {
      MsgBox, 262144, ERROR, % "Cant create " TMP
	  return 0
   }
   if !part {
      print(">> Finding active boot partition")
      boot := find_block("boot")
   } else {
      print(">> Finding " part " partition")
      boot := find_block(part)
   }
   if !boot {
      print(">> Cant find dest partition")
	  return 0
   }
   boot_base := ubasename(boot)
   print(">> Updating ramdisk: " boot_base)
   result .= adb_shell("cd " TMP " && magiskboot unpack -h -n " """" boot """")
   if !exist_file(TMP "/ramdisk.cpio") {
      write_file(result, general_log)
      MsgBox, 262144, ERROR, % "Some problem unpacking " boot_base
	  return 0
   }
   format .= decompress(TMP "/ramdisk.cpio", TMP "/ramdisk_.cpio")
   delete_file(TMP "/ramdisk.cpio")
   delete_file(TMP "/ramdisk_.cpio")
   if format {
      result .= "Ramdisk with compression: " format "`n"
	  format2 := decompress(ramdisk, TMP "/ramdisk.cpio")
	  if format2 {		  
		  if !recompress(TMP "/ramdisk.cpio", format, TMP "/ramdisk_.cpio")
			 return 0
	  } else {
	     if !recompress(ramdisk, format, TMP "/ramdisk_.cpio")
			 return 0
	  } 
   } else {
      format2 := decompress(ramdisk, TMP "/ramdisk_.cpio")
	  if !format2
	     result .= adb_shell("cp -f " """" ramdisk """" " " TMP "/ramdisk_.cpio")
   }
   delete_file(TMP "/ramdisk.cpio")
   result .= adb_shell("cp -f " TMP "/ramdisk_.cpio" " " TMP "/ramdisk.cpio")
   if !remove_magisk(TMP)
      return 0
   if exist_file(TMP "/ramdisk.cpio") {
      result .= adb_shell("cd " TMP " && magiskboot repack " """" boot """")
	  if exist_file(TMP "/new-boot.img") {
	     if !update(TMP "/new-boot.img", boot, true) {
		    write_file(result, general_log)
	        return 0
		 }
	  } else {
	     write_file(result, general_log)
	     MsgBox, 262144, ERROR, % "Some problem building new boot.img"
	     return 0
	  }
   } else {
       write_file(result, general_log)
	   MsgBox, 262144, ERROR, % "Some problem updating new ramdisk"
	   return 0
   }
   write_file(result, general_log)
   return 1
}
update_ramdisk_push(ramdisk, part := "") {
    global exist_device
    global device_mode
    global serial
    global general_log
    if (serial && !check_active(serial))
       return 0
    if (device_mode="fastboot") {
	    MsgBox, 262144, ERROR, The update_ramdisk_push function is not supported from fastboot
	    return 0
    }
	TMP := ensure_tmp()
	if !TMP
	   return 0
    if !push(ramdisk, TMP)
       return 0
	if update_ramdisk(TMP "/" basename(ramdisk), part) {
	   if exist_file(TMP "/" basename(ramdisk))
	      delete_file(TMP "/" basename(ramdisk))
	   return 1
	} else {
	   return 0
	}
}
update_kernel(kernel, part := ""){
   global exist_device
   global device_mode
   global serial
   global general_log
   if (serial && !check_active(serial))
      return 0
   if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The update_ramdisk function is not supported from fastboot
	   return 0
   }
   run_binary("magiskboot") && magiskboot := true
   if !magiskboot {
	   MsgBox, 262144, ERROR, Your current Recovery does not support kernel updating
	   return 0 
   }
   if !exist_file(kernel) {
	   MsgBox, 262144, ERROR, % "Cant find " kernel " on the device"
       return 0
   }
   TMP := ensure_tmp()
   if !TMP
	  return 0
   TMP := TMP "/update_0001"
   delete_dir(TMP)
   if !create_dir(TMP) {
      MsgBox, 262144, ERROR, % "Cant create " TMP
	  return 0
   }
   if !part {
      print(">> Finding active boot partition")
      boot := find_block("boot")
   } else {
      print(">> Finding " part " partition")
      boot := find_block(part)
   }
   if !boot {
      print(">> Cant find dest partition")
	  return 0
   }
   boot_base := ubasename(boot)
   print(">> Updating kernel: " boot_base)
   result .= adb_shell("cd " TMP " && magiskboot unpack -h -n " """" boot """")
   if !exist_file(TMP "/kernel") {
      write_file(result, general_log)
      MsgBox, 262144, ERROR, % "Some problem unpacking " boot_base
	  return 0
   }
   format .= decompress(TMP "/kernel", TMP "/kernel_")
   delete_file(TMP "/kernel")
   delete_file(TMP "/kernel_")
   if format {
      result .= "Kernel with compression: " format "`n"
	  format2 := decompress(kernel, TMP "/kernel")
	  if format2 {		  
		  if !recompress(TMP "/kernel", format, TMP "/kernel_")
			 return 0
	  } else {
	     if !recompress(kernel, format, TMP "/kernel_")
			 return 0
	  }
   } else {
      format2 := decompress(kernel, TMP "/kernel_")
	  if !format2
	     result .= adb_shell("cp -f " """" kernel """" " " TMP "/kernel_")
   }
   delete_file(TMP "/kernel")
   result .= adb_shell("cp -f " TMP "/kernel_" " " TMP "/kernel")
   if !remove_magisk(TMP)
      return 0
   if exist_file(TMP "/kernel") {
      result .= adb_shell("cd " TMP " && magiskboot repack " """" boot """")
	  if exist_file(TMP "/new-boot.img") {
	     if !update(TMP "/new-boot.img", boot, true) {
		    write_file(result, general_log)
	        return 0
		 }
	  } else {
	     write_file(result, general_log)
	     MsgBox, 262144, ERROR, % "Some problem building new boot.img"
	     return 0
	  }
   } else {
       write_file(result, general_log)
	   MsgBox, 262144, ERROR, % "Some problem updating new kernel"
	   return 0
   }
   write_file(result, general_log)
   return 1
}
update_kernel_push(kernel, part := "") {
    global exist_device
    global device_mode
    global serial
    global general_log
    if (serial && !check_active(serial))
       return 0
    if (device_mode="fastboot") {
	    MsgBox, 262144, ERROR, The update_kernel_push function is not supported from fastboot
	    return 0
    }
	TMP := ensure_tmp()
	if !TMP
	   return 0
    if !push(kernel, TMP)
       return 0
	if update_kernel(TMP "/" basename(kernel), part) {
	   if exist_file(TMP "/" basename(kernel))
	      delete_file(TMP "/" basename(kernel))
	   return 1
	} else {
	   return 0
	}
}
install_recovery_ramdisk(part := "") {
    global exist_device
    global device_mode
    global serial
    global general_log
    if (serial && !check_active(serial))
       return 0
    if (device_mode="fastboot") {
	    MsgBox, 262144, ERROR, The install_recovery_ramdisk function is not supported from fastboot
	    return 0
    }
   TMP := ensure_tmp()
   if !TMP
	   return 0
   if !get_twrp_ramdisk(TMP "/twrp_.cpio")
	   return 0
   if !part {
      if !update_ramdisk(TMP "/twrp_.cpio")
	     return 0
   } else {
      if !update_ramdisk(TMP "/twrp_.cpio", part)
	     return 0
   }
   return 1
}
decompress(file, dest := ""){
   global exist_device
   global device_mode
   global serial 
   global general_log
   if (serial && !check_active(serial))
      return
   if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The decompress function is not supported from fastboot
	   return
   }
   run_binary("magiskboot") && magiskboot := true
   if !magiskboot {
	   MsgBox, 262144, ERROR, Cant find magiskboot
	   return
   }
   if !exist_file(file) {
	   MsgBox, 262144, ERROR, % "Cant find " file " on the device"
       return
   }
   base := "magiskboot decompress " """" file """"
   if dest
      base .= " " """" dest """"
   try := adb_shell(base)
   if !(try ~= "\braw\b"){
      format := Trim(RegExReplace(try, "(?:^|.*\R).*format: \[(.+?(?=\])).*", "$1"), A_Space)
   }
   return format
}
recompress(file, format, dest := ""){
   global exist_device
   global device_mode
   global serial 
   global general_log
   if (serial && !check_active(serial))
      return 0
   if (device_mode="fastboot") {
	   MsgBox, 262144, ERROR, The recompress function is not supported from fastboot
	   return 0
   }
   run_binary("magiskboot") && magiskboot := true
   if !magiskboot {
	   MsgBox, 262144, ERROR, Cant find magiskboot
	   return 0
   }
   if !exist_file(file) {
	   MsgBox, 262144, ERROR, % "Cant find " file " on the device"
       return 0
   }
   base := "magiskboot compress=" format " " """" file """"
   if dest
      base .= " " """" dest """"
   base .= " && echo Success"
   result := adb_shell(base)
   if !InStr(result, "Success"){
      write_file(result, general_log)
      MsgBox, 262144, ERROR, % "Some problem compressing " file " as " format
	  return 0
   }
   return 1
}
save(value, with, in) {
   global HERE, TOOL, secure_user_info, general_log
   in := GetFullPathName(in)
   (!(value ~= "^[a-zA-Z_$][a-zA-Z0-9_$]*$")) ? unexpected := "Invalid variable name--->" value : InStr(with, "`n") ? unexpected := "Only single line preferences are allowed to be saved"
   if unexpected
      return 0
   if (secure_user_info && !(in ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
	  MsgBox, 262148, Save preferences, % " Attempting to save a file outside of common paths:`n`n " in "`n`n Do you want to allow it?"
	  IfMsgBox No
	  {
	     return 0
	  }
   }
   try {
      IniWrite, % with, % in, CUSTOM, % value
   } catch {
	  write_file("There was a problem saving the preference: " value "=" with, general_log)
	  return 0
   }
   return 1
}
enable(key) {
   try
      GuiControl, 1:, % key, 1
   catch
      return 0
   return 1
}
disable(key) {
   try
      GuiControl, 1:, % key, 1
   catch
      return 0
   return 1
}
hide(key) {
   try
      GuiControl, 1: Hide, % key
   catch
      return 0
   return 1
}
show(key) {
   try
      GuiControl, 1: Show, % key
   catch
      return 0
   return 1
}
gotolink(link) {
   if (link ~= "i)^(?:\b[a-z\d.-]+:\/\/[^<>\s]+|\b(?:(?:(?:[^\s!@#$%^&*()_=+[\]{}\|`;:'"",.<>/?]+)\.)+(?:ac|ad|aero|ae|af|ag|ai|al|am|an|ao|aq|arpa|ar|asia|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|biz|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|cat|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|coop|com|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|edu|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gov|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|info|int|in|io|iq|ir|is|it|je|jm|jobs|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mil|mk|ml|mm|mn|mobi|mo|mp|mq|mr|ms|mt|museum|mu|mv|mw|mx|my|mz|name|na|nc|net|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|org|pa|pe|pf|pg|ph|pk|pl|pm|pn|pro|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tel|tf|tg|th|tj|tk|tl|tm|tn|to|tp|travel|tr|tt|tv|tw|tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|xn--0zwm56d|xn--11b5bs3a9aj6g|xn--80akhbyknj4f|xn--9t4b11yi5a|xn--deba0ad|xn--g6w251d|xn--hgbk6aj7f53bba|xn--hlcj6aya9esc7a|xn--jxalpdlp|xn--kgbechtv|xn--zckzah|ye|yt|yu|za|zm|zw)|(?:(?:[0-9]|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.){3}(?:[0-9]|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]))(?:[`;/][^#?<>\s]*)?(?:\?[^#<>\s]*)?(?:#[^<>\s]*)?(?!\w))$")    
   {
	  try {
		 Run, % link
	  } catch {
		 MsgBox, 262144, ERROR,  % "Cant open link: `n`n" link
		 return 0
	  }
   } else {
      unexpected := "Invalid URL: " link
	  return 0
   }
   return 1
}
color(hex, key) {
   try {
     GuiControl, % "1: +c" hex, % key
	  GuiControl, 1:+AltSubmit, tabs
	  GuiControlGet, currenttab, 1:, tabs
	  if currenttab is integer
	  {
		  Loop {
			 if (A_Index!=currenttab) {
				GuiControl, 1:choose, tabs, % A_Index
				GuiControl, 1:choose, tabs, % currenttab
				break
			 }
		  }
	  }
	  GuiControl, 1:-AltSubmit, tabs
   } catch {
      return 0
   }
   return 1
}
move(key, to) {
   try
      GuiControl, 1:Move, % key, % to
   catch
      return 0
   return 1
}
getsaved(file) {
   if FileExist(file) {
	  if RegexMatch(read_file(file), "is)(\[CUSTOM\]\K.*?)(?=(\R$)|\[)", section) {
		 Loop, parse, section, `n, `r
		 {
			if A_LoopField && (_pos := InStr(A_LoopField, "=")) {
				try
				   GLOBAL[SubStr(A_LoopField, 1, _pos - 1)] := SubStr(A_LoopField, _pos + 1)
				catch
				   return 0
			}
		 }
	  }
   } else {
       unexpected := "Cant find: " file
	   return 0
   }
   return 1
}
delete(part) {
   global custom_parts
   try {
      custom_parts.Push({part:part, to_remove:true})
   } catch {
      unexpected := "Cant append partition: " part
      return 0
   }
   return 1
}
create(part, with) {
   global custom_parts
   if !(size := to_bytes(with)) {
	   unexpected := "Invalid SIZE: " with
	   return 0
   }
	try {
		custom_parts.Push({part:part, size:size})
	} catch {
       unexpected := "Cant append partition: " part
	    return 0
	}
	return 1
}
install(file, in, with:="", is_zip:=false) {
   global install_files
   (!IsObject(install_files)) ? install_files:=[]
   if !InStr(FileExist(file), "A") {
      unexpected := "Cant find file: " file
	   return 0
	}
	try {
      install_files.Push({file:file, part:Trim(in), extra:Trim(with), is_zip:is_zip, install:true})
	} catch {
      unexpected := "Cant append file: " file
      return 0
	}
	return 1
}
unlock(){
   global secure_user_info, skip_functions
   if question("Unlock","Do you want to disable all security during installation?`n`nNOTE: This is not necessarily unsafe if the Script is from a trusted source.")
      secure_user_info:="",skip_functions:=""
   return 1
}
wipe_env(reset := false) {
   global install_files, serial
   serial := ""
   FD_CURRENT ? load_config(,,,,,true)
   install_files := [], custom_parts := []
   enable_bar()
   disable_bar()
   if reset {
     GuiControl, 1:, partition, None
     GuiControl, 1:, reboot, 0
	  GuiControl, 1:, format_data, 0
	  GuiControl, 1:, disable_verify, 0
	  GuiControl, 1:, disable_config_overwrite, 0
	  GuiControl, 1:, force_install, 0
	  GuiControl, 1:, ensure_recovery, 0
	  GuiControl, 1:, all_formats, 0
	  GuiControl, 1:Choose, default_mode, 1
	  GuiControl, 1:, default_slot, auto
	  gosub update_preferences
   }
}
read_config(file) {
   global secure_user_info, current, anti_notspam, CONFIG
   if !InStr(FileExist(file), "A") {
      MsgBox, 262144, ERROR, % "Cant find file: " file
	  return 0
   }
   CONFIG:=file
   if load_config(read_file(file),,,,,true) {
      result:=1
   } else {
      print(">> " basename(file) " stopped!")
      result:=0
   }
   secure_user_info:=false, anti_notspam:=false
   return result
}

; Extra Definitions
HeaderColors := {}
GuiFont := GuiDefaultFont()
color := GetSysColor(15)
textz := GuiFont.Size
style := GuiFont.Name
start_date := A_Now
StringLower, build_author, maintainer_build_author
FormatTime, start_date,, dd/M/yyyy   hh:mm
boxH := height - 50
boxW := weight - 20

; Hot image
Gui, Dummy:Add, Pic, hwndclean1, % current "\images\clean.jpg"
SendMessage, STM_GETIMAGE:=0x0173, 0, 0, , ahk_id %clean1%
clean_normal := ErrorLevel
clean_hot := current "\images\clean2.jpg"

; Interface
Gui, +LastFound
Gui, margin, %mx%, %my%
Gui, Font, s20, Arial Black
Gui, Add, Text, Y+0 c00adc9 Section vheader, %name%
Gui, Font, s10, %style%
Gui, Add, Text, X+0 YP+10 c1FB012 vline, ------
Gui, Add, Button, center X+0 YS+5 h30 w100 gfind_device vfind_device, Find My Device
Gui, Add, Tab3, x%mx% Y+10 vtabs hwndtabshw Group,, Home|Reboot|Settings|Wifi|Info
Gui, Tab, 1
Gui, Add, GroupBox, x%mx% Y+5 h%boxH% w%boxW% c254EC5, Build: %build_author%/%build_date%
Gui, Add, Text, YP+30 XP+10 Section, Select .IMG or Config: 
Gui, Add, Button, center X+10 YP h20 w100 gselect, Select File
Gui, Add, Button, center X+5 YP h20 w20 hwndclean gclean
Opt1 := [0, clean_normal]                                          
Opt2 := {2: clean_hot}                                      
If !ImageButton.Create(clean, Opt1, Opt2) {
   MsgBox, 262144, ImageButton Error: clean, % ImageButton.LastError
   return
}
Gui, Add, Text, XS Y+10, Destination Partition: 
Gui, Add, Edit, center X+20 YP h20 w100 vpartition, None
Gui, Add, Edit, x%mx% Y+15 h135 w%boxW% vconsole hwndgeneralbox 0x200 border HScroll ReadOnly, >> Start Tool: %start_date% in W%winver%`r`n
Gui, Add, Progress, R0-100 XP Y+0 h60 w130 -Smooth 0x200 BackgroundC9C9C9 c3d484a vinstall_bar Section, 0
Gui, Add, Button, center XP YP h60 w130 0x200 border ginstall vinstall, INSTALL
Gui, Font, s9, %style%
Gui, Add, Checkbox, YP+4 XS+155 vformat_data gsave_preferences Section, Format Data
Gui, Add, Checkbox, XS Y+4 vdisable_verify gsave_preferences, Disable Verify
Gui, Add, Checkbox, XP Y+4 vreboot gsave_preferences, Reboot
Gui, Font, s10, %style%
Gui, Tab, 2
Gui, Add, Button, center x%mx% Y+10 h60 w130 0x200 border gonly_reboot vonly_reboot Section, Reboot
Gui, Add, Button, center X+10 YP h60 w130 0x200 border greboot_fastboot vreboot_fastboot, Fastboot
Gui, Add, Button, center XP-70 Y+10 h60 w130 0x200 border greboot_recovery, Recovery
Gui, Tab, 3
Gui, Font, s10, Arial Black
Gui, Add, GroupBox, x%mx% Y+5 h%boxH% w%boxW% c254EC5 Section, General Configs
Gui, Font, s10, %style%
Gui, Add, Button, center XP+30 YP+30 h40 w100 ginstall_manager, Install Manager
Gui, Add, Button, center X+10 YP h40 w100 gdevice_manager, Device Manager
Gui, Font, s10, Arial Black
Gui, Add, GroupBox, XS Y+10 h%boxH% w%boxW% c254EC5, Extra Configs
Gui, Font, s10, %style%
Gui, Add, Text, XP+10 YP+30 Section, Default mode: 
Gui, Add, DropDownList, AltSubmit center X+13 YP w100 vdefault_mode gsave_preferences, fastboot|fastbootD
Gui, Add, Text, XS Y+4, Default SLOT: 
Gui, Add, Edit, center X+10 YP h20 w100 +Lowercase gsave_preferences vdefault_slot, auto
Gui, Add, Checkbox, XS+10 Y+10 vpreferences gsave_preferences, Save my preferences
Gui, Add, Checkbox, XP Y+4 vforce_install gsave_preferences, Force the Installation
Gui, Add, Checkbox, XP Y+4 vensure_recovery gsave_preferences, Prioritize Recovery
Gui, Add, Checkbox, XP Y+4 vensure_shell gsave_preferences, Prioritize Shell
Gui, Add, Checkbox, XP Y+4 vall_formats gsave_preferences, Enable all file formats
Gui, Add, Checkbox, XP Y+4 vconfig_tracking gsave_preferences AltSubmit, Enable Config Tracking
Gui, Tab, 4
Gui, Font, s10, Arial Black
Gui, Add, GroupBox, x%mx% Y+5 h%boxH% w%boxW% c254EC5 Section, Wireless Connetion
Gui, Font, s10, %style%
Gui, Add, Text, YP+30 XP+10 , Although ADB supports Wi-Fi connection,`nit is not recommended due to network failures,`nslower processes and the requirement of the`nUSB Cable prior to the wireless connection`n(The use of USB depends on the device)
Gui, Font, s10, Arial Black
Gui, Add, GroupBox, XS Y+10 h%boxH% w%boxW% c254EC5, TCP/IP
Gui, Font, s10, %style%
Gui, Add, Text, XP+10 YP+30 Section, IP: 
Gui, Add, Edit, center X+10 YP h20 w100 vip hwndiphw,
Gui, Add, Text, X+20 YP, PORT: 
Gui, Add, Edit, center X+10 YP h20 w60 vport hwndport, 5555
Gui, Add, Button, center XS+20 Y+20 h40 w100 gconnect, Connect
Gui, Add, Button, center X+10 YP h40 w100 gdisconnect, Disable
Gui, Tab, 5
Gui, Font, s10, Arial Black
Gui, Add, GroupBox, x%mx% Y+5 h%boxH% w%boxW% c254EC5, General Info
Gui, Font, s10, %style%
Gui, Add, Text, YP+30 XP+10 , This tool automates and improves the`nfastboot users experience.
Gui, Add, Text, Y+10 XP+10 cgreen Section, Tool Name:
if (original_author!=maintainer_build_author)
   Gui, Add, Text, Y+10 XP cgreen, Maintainer:
Gui, Add, Text, Y+10 XP cgreen, Developer:
Gui, Add, Text, Y+10 XP cgreen, Version:
Gui, Add, Text, Y+10 XP cgreen, Status:
Gui, Add, Text, Y+10 XP cgreen, Build Name:
Gui, Add, Text, X+40 YS, %name%
if (original_author!=maintainer_build_author)
   Gui, Add, Text, XP Y+10, %maintainer_build_author%
Gui, Add, Text, XP Y+10, %original_author%
Gui, Add, Text, XP Y+10, %version%
Gui, Add, Text, XP Y+10, %status%
Gui, Add, Text, XP Y+10, %build_author%/%build_date%
Gui, Add, Picture, XS+20 Y+2 h80 w190 gdonate, % current "\images\support.png"
toolid := WinExist()
Gui, Show, w%weight% h%height%, %title%_%original_author%
WinGetPos, toolX, toolY, toolW, toolH, ahk_id %toolid%
OnMessage(WM_LBUTTONDOWN := 0x201, "eventHandler")
OnMessage(WM_LBUTTONUP := 0x202, "eventHandler")
OnMessage(WM_LBUTTONDBLCLK := 0x203, "eventHandler")
OnExit, GuiClose
enable_bar()
disable_bar()
gosub update_preferences
print(">> Checking integrity")
check_bin()
web_config("https://raw.githubusercontent.com/BlassGO/auto_img_request/main/support.config", 3000, true)
load_config(,,,,,true)
secure_user_info:=""
return

device_manager:
	hidden_devices := true
	(clicktime<300) ? hidden_devices := false
	find_device(1, true, , true)
return

find_device:
	serial := "", hidden_devices := true
	(clicktime<300) ? hidden_devices := false
	IniRead, usb_msg, % current "\configs.ini", GENERAL, usb_msg, 0
	if (usb_msg=1) {
	   update_drivers()
	   find_device(1, true, true)
	} else {
	   help(current "\images\dev_options.png", "Dont forget to turn on USB debugging.")
	   IniWrite, 1, % current "\configs.ini", GENERAL, usb_msg
	}
return

connect:
	Gui, 1:Submit, NoHide
	if !(ip ~= ip_check) {
	   MsgBox, 262144, HELP, % "Invalid IP: """ ip """"
	   return
	}
	if !(port ~= "^\d+$") {
	   MsgBox, 262144, HELP, % "Invalid PORT: """ port """"
	   return
	}
	IniRead, preferences, % current "\configs.ini", GENERAL, preferences, 0
	if (preferences==1) {
	   IniWrite, %ip%, % current "\configs.ini", GENERAL, ip
	   IniWrite, %port%, % current "\configs.ini", GENERAL, port
	}
	wireless_IP := ip, wireless_PORT := port, wireless_FORCE  := true
	print(">> IP[" wireless_IP "] : PORT[" wireless_PORT "]")
	find_device(2, true, true)
return

disconnect:
wireless_IP := "", wireless_PORT := "", wireless_FORCE  := false
print(">> TCP/IP: Disabled")
return

clean:
	wipe_env(true)
	ToolTip, Cleaning Configs...
	SetTimer, RemoveToolTip, -1000
return

donate:
	Run, https://paypal.me/blassgohuh?country.x=EC&locale.x=es_XC
return

console:
	GuiControlGet, Prev, 1:, console
	ToolTip, Copied log
	Clipboard := "", Clipboard := Prev
	SetTimer, RemoveToolTip, -1000
return

RemoveToolTip:
	ToolTip
	DllCall("SetFocus", "Ptr", 0)
return

save_preferences:
	if secure_user_info
	   return
	Gui, 1:Submit, NoHide
	GuiControlGet, default_slot, 1:, default_slot
	IniWrite, %preferences%, % current "\configs.ini", GENERAL, preferences
	if (preferences=1) {
		IniWrite, %disable_verify%, % current "\configs.ini", GENERAL, disable_verify
		IniWrite, %reboot%, % current "\configs.ini", GENERAL, reboot
		IniWrite, %format_data%, % current "\configs.ini", GENERAL, format_data
		IniWrite, %disable_config_overwrite%, % current "\configs.ini", GENERAL, disable_config_overwrite
		IniWrite, %force_install%, % current "\configs.ini", GENERAL, force_install
		IniWrite, %ensure_recovery%, % current "\configs.ini", GENERAL, ensure_recovery
      IniWrite, %ensure_shell%, % current "\configs.ini", GENERAL, ensure_shell
		IniWrite, %all_formats%, % current "\configs.ini", GENERAL, all_formats
		IniWrite, %default_mode%, % current "\configs.ini", GENERAL, default_mode
		IniWrite, %default_slot%, % current "\configs.ini", GENERAL, default_slot
		IniWrite, %config_tracking%, % current "\configs.ini", GENERAL, config_tracking
	}
return

update_preferences:
	IniRead, preferences, % current "\configs.ini", GENERAL, preferences, 0
	GuiControl, 1:Choose, default_mode, 1
	if (preferences=1) {
		IniRead, disable_verify, % current "\configs.ini", GENERAL, disable_verify, 0
		IniRead, reboot, % current "\configs.ini", GENERAL, reboot, 0
		IniRead, format_data, % current "\configs.ini", GENERAL, format_data, 0
		IniRead, disable_config_overwrite, % current "\configs.ini", GENERAL, disable_config_overwrite, 0
		IniRead, force_install, % current "\configs.ini", GENERAL, force_install, 0
		IniRead, ensure_recovery, % current "\configs.ini", GENERAL, ensure_recovery, 0
      IniRead, ensure_shell, % current "\configs.ini", GENERAL, ensure_shell, 0
		IniRead, all_formats, % current "\configs.ini", GENERAL, all_formats, 0
		IniRead, default_mode, % current "\configs.ini", GENERAL, default_mode, 1
		IniRead, default_slot, % current "\configs.ini", GENERAL, default_slot, auto
		IniRead, config_tracking, % current "\configs.ini", GENERAL, config_tracking, 0
		IniRead, ip, % current "\configs.ini", GENERAL, ip, 0
		IniRead, port, % current "\configs.ini", GENERAL, port, 5555
      (!ip) ? ip:=""
		GuiControl, 1:, preferences, %preferences%
		GuiControl, 1:, disable_verify, %disable_verify%
		GuiControl, 1:, reboot, %reboot%
		GuiControl, 1:, format_data, %format_data%
		GuiControl, 1:, disable_config_overwrite, %disable_config_overwrite%
		GuiControl, 1:, force_install, %force_install%
		GuiControl, 1:, ensure_recovery, %ensure_recovery%
      GuiControl, 1:, ensure_shell, %ensure_shell%
		GuiControl, 1:, all_formats, %all_formats%
		GuiControl, 1:Choose, default_mode, %default_mode%
		GuiControl, 1:, default_slot, %default_slot%
		GuiControl, 1:, config_tracking, %config_tracking%
		GuiControl, 1:, ip, %ip%
		GuiControl, 1:, port, %port%
	}
return

select:
	Gui, 1:Submit, NoHide
	GuiControlGet, part, 1:, partition
	IniRead, zip_msg, % current "\configs.ini", GENERAL, zip_msg, 0
	ext:=""
	if (all_formats=1) {
	   ext := "*.*"
	} else if formats {
      if IsObject(formats) {
         for count, value in formats {
            ext ? ext .= ";" 
            ext .= "*." value
         }
      } else {
         ext := "*." formats
      }
   }
	(!ext) ? ext := "*.img;*.config;*.zip;*.apk"
	if (part && part!="None") && (install_files[install_files.MaxIndex()].part!=part) {
      install_files[install_files.MaxIndex()].part := part
   }
	FileSelectFile, file, 1,, Please select some IMG to Install, (%ext%)
	if !file {
	  print(">> Warning: No Selection")
	} else {
	  ext := extname(file)
	  if (ext="zip"||ext="apk") {
		 print(">> Loaded ZIP: " + basename(file))
		 GuiControl, 1:, partition, ZIP FILE
		 install(file, "ZIP FILE",,true)
		 if (zip_msg!=1) {
			help(current "\images\recoverys.png", "The installation of ZIPs requires a Custom Recovery, so`nAll loaded ZIPs will be installed after the IMGs and not in load order")
			IniWrite, 1, % current "\configs.ini", GENERAL, zip_msg
		 }
	  } else if (ext="config") {
		 print(">> Loaded Config: " + basename(file))
		 read_config(file)
	  } else {
		 print(">> Loaded: " + basename(file))
		 GuiControl, 1:, partition, % simplename(file)
		 install(file, simplename(file))
	  }
	}
return

only_reboot:
   Gui, 1:Submit, NoHide
	if (serial && !check_active(serial))
	   return
	if !exist_device {
	    MsgBox, 262144, HELP, First find your device
	} else {
		print(">> Rebooting...")
		if (device_mode!="fastboot") {
		   (ensure_shell||InStr(adb_serial("reboot"), "refused")) ? adb_shell("reboot")
		} else {
		   fastboot_serial("reboot")
		}
      exist_device=
      device_mode=
		remember_mode = booted
	}
return

reboot_recovery:
   Gui, 1:Submit, NoHide
	if (serial && !check_active(serial))
	   return
	if !exist_device {
	    MsgBox, 262144, HELP, First find your device
	    return
	} else {
		print(">> Rebooting in recovery...")
		if (device_mode!="fastboot") {
		   (ensure_shell||InStr(adb_serial("reboot recovery"), "refused")) ? adb_shell("reboot recovery")
		} else {
		   fastboot_serial("reboot recovery")
		}
      exist_device=
      device_mode=
		remember_mode = recovery
	}
return

reboot_fastboot:
	Gui, 1:Submit, NoHide
	if (serial && !check_active(serial))
	   return
	if !exist_device {
	  MsgBox, 262144, HELP, First find your device
	  return
	} else {
		if (device_mode!="fastboot") {
		   ensure_fastboot()
		} else {
		   print(">> Rebooting in fastboot...")
		   (default_mode=1) ? fastboot_serial("reboot bootloader") : fastboot_serial("reboot fastboot")
		}
      exist_device=
      device_mode=
		find_device(20) ? (device_mode="fastboot") ? fastbootd ? print(">> Mode: fastbootd") : print(">> Mode: fastboot")
	}
return

install:
	Gui, 1:Submit, NoHide
	GuiControlGet, part, 1:, partition
	install_fail:=false
	if (serial && !check_active(serial))
	   return
	if !exist_device {
	  MsgBox, 262144, HELP, First find your device
	  return
	}
	if (part && part!="None") && (install_files[install_files.MaxIndex()].part!=part) {
	   install_files[install_files.MaxIndex()].part := part
	}
	to_install=0
   to_install_zip=0
   for index, file in install_files {
      if file.install {
         if file.is_zip {
            to_install_zip++
         } else {
			   to_install++
         }
      }
   }
   to_remove=0
   to_create=0
   if custom_parts.MaxIndex() {
      if !fastbootd && (default_mode=1) {
         if question("HELP", "Deleting or creating partitions requires FastbootD mode`n`nDo you want to change the default mode to FastbootD?") {
            print(">> Default mode: FastbootD")
			   GuiControl, 1:, default_mode, 2
         }
            
      }
      for index, part in custom_parts {
         if part.to_remove {
            to_remove++
         } else {
            to_create++
         }
      }
   }
	if (!to_install && !to_install_zip && !to_remove && !to_create) && (format_data!=1) {
	  MsgBox, 262144, HELP, Please enable at least one action/installation
	  return
   } else if !to_install && to_install_zip {
	  goto recovery_install
   }

fastboot_install:
	if !ensure_fastboot()
	   return
	fastbootd ? print(">> Mode: fastbootd") : print(">> Mode: fastboot")
	if !unlocked {
	  MsgBox, 262144, WARNING, You need to unlock your bootloader for security
	  return
	}
	if to_remove {
      progress := Round(100/to_remove)
	   FD_CURRENT ? load_config("section ""before_delete""",,, FD_CURRENT)
      enable_bar()
      for index, part in custom_parts {
         if part.to_remove {
            if delete_partition(part.part) {
               add_progress(progress)
            } else {
               disable_bar()
               return
            }
         }
      }
      disable_bar()
	   FD_CURRENT ? load_config("section ""after_delete""",,, FD_CURRENT)
	}
   if to_create {
      progress := Round(100/to_create)
	   FD_CURRENT ? load_config("section ""before_create""",,, FD_CURRENT)
      enable_bar()
      for index, part in custom_parts {
         if !part.to_remove && part.size {
            if create_partition(part.part, part.size) {
               add_progress(progress)
            } else {
               disable_bar()
               return
            }
         }
      }
      disable_bar()
	   FD_CURRENT ? load_config("section ""after_create""",,, FD_CURRENT)
	}
	FD_CURRENT ? load_config("section ""before_img""",,, FD_CURRENT)
	enable_bar()
	progress := Round(100/to_install)
   for index, file in install_files {
      if file.install && !file.is_zip {
         if !(extra:=file.extra) {
            if (disable_verify=1) && (file.part ~= "^vbmeta") {
			      print(">> Disabling verified boot...")
			      extra:="--disable-verity --disable-verification"
		      }
         }
         if install_img(file.file, file.part, extra) {
            add_progress(progress)
         } else {
            install_fail:=true
            break
         }
      }
   }
	if !install_fail {
	   FD_CURRENT ? load_config("section ""after_img""",,, FD_CURRENT)
	   if (format_data=1) {
		  FD_CURRENT ? load_config("section ""before_format""",,, FD_CURRENT)
		  format_data()
		  FD_CURRENT ? load_config("section ""after_format""",,, FD_CURRENT)
	   }
	}

recovery_install:
	disable_bar()
   if !install_fail {
      if to_install_zip {
         FD_CURRENT ? load_config("section ""before_zip""",,, FD_CURRENT)
         print(">> Loading ZIP installation")
         enable_bar()
         progress := Round(100/to_install_zip)
         for index, file in install_files {
            if file.install&&file.is_zip {
               if flash_zip_push(file.file) {
                  add_progress(progress)
               } else {
                  install_fail := true
                  break
               }
            }
         }
         disable_bar()
         FD_CURRENT ? load_config("section ""after_zip""",,, FD_CURRENT)
	   }
      if !install_fail {
         FD_CURRENT ? load_config("section ""after_all""",,, FD_CURRENT)
         if (reboot=1) {
            FD_CURRENT ? load_config("section ""before_reboot""",,, FD_CURRENT)
            gosub only_reboot
            FD_CURRENT ? load_config("section ""after_reboot""",,, FD_CURRENT)
         }
         FD_CURRENT ? load_config("section ""after""",,, FD_CURRENT)
         print(">> Done")
	   }
   }
return

Esc::
finish:
GuiEscape:
GuiClose:
	AnimateWindow(toolid, 500, EXIT_ANIM)
	ExitApp
	Exit
