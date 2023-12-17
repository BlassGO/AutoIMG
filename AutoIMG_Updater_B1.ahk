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
#include edit_color.ahk
#include obj_dump.ahk
#include crypt.ahk
#include gui_resize.ahk

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
version = 1.3.3
status = Beta
build_date = 16.12.2023

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
apktool := tools "\apktool.jar"
sign := tools "\sign.jar"
zipalign := tools "\zipalign.exe"
7za := tools "\7za.exe"
busybox := extras "\busybox"
dummy_img := extras "\dummy.img"
app_manager := extras "\app_manager"

; Global Regex
ip_check := "((^\s*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\s*$)|(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$))"

; Check dependencies
Folders := current "," current "\images," tools "," extras
Files := fastboot "," adb "," busybox "," dummy_img "," apktool "," zipalign "," 7za "," sign "," app_manager "," tools "\AdbWinApi.dll," tools "\AdbWinUsbApi.dll,"
Files .= current "\images\dev_options.png," current "\images\clean.jpg," current "\images\clean2.jpg," current "\images\support.png," current "\images\usb.png," current "\images\turn_on.png," current "\images\recoverys.png," current "\images\dev_wir.png," current "\images\app.png," current "\images\app_guide.png," current "\images\unauthorized.png," current "\images\back.png," current "\images\delete.png," current "\images\export.png," current "\images\file.png," current "\images\folder.png," current "\images\link.png," current "\images\view.png,"
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
Loop 2
    DllCall( "ChangeWindowMessageFilter", uInt, "0x" (i:=!i?49:233), uint, 1)

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
SetEditCueBanner(HWND, Cue) {  ; requires AHL_L, thanks to just.me (ahk forum)
   Static EM_SETCUEBANNER := (0x1500 + 1)
   Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
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
isBinFile(Filename,NumBytes:=32,Minimum:=4,complexunicode:=1) {
	
	file:=FileOpen(Filename,"r")
	file.Position:=0 ;force position to 0 (zero)
	nbytes:=file.RawRead(rawbytes,NumBytes) ;read bytes
	file.Close() ;close file
	
	if (nbytes < Minimum) ;recommended 4 minimum for unicode detection
		return 0 ;asume text file, if too short
	
	t:=0, i:=0, bytes:=[] ;Initialize vars
	
	loop % nbytes ;create c-style bytes array
		bytes[(A_Index-1)]:=Numget(&rawbytes,(A_Index-1),"UChar")
	
	;determine BOM if possible/existant
	if (bytes[0]=0xFE && bytes[1]=0xFF)
		|| (bytes[0]=0xFF && bytes[1]=0xFE)
		return 0 ;text Utf-16 BE/LE file
	if (bytes[0]=0xEF && bytes[1]=0xBB && bytes[2]=0xBF)
		return 0 ;text Utf-8 file
	if (bytes[0]=0x00 && bytes[1]=0x00
		&& bytes[2]=0xFE && bytes[3]=0xFF)
		|| (bytes[0]=0xFF && bytes[1]=0xFE
		&& bytes[2]=0x00 && bytes[3]=0x00)
		return 0 ;text Utf-32 BE/LE file
		
	while(i<nbytes) {	
		;// ASCII
		if( bytes[i] == 0x09 || bytes[i] == 0x0A || bytes[i] == 0x0D
			|| (0x20 <= bytes[i] && bytes[i] <= 0x7E) ) {
			i += 1
			continue
		}
		;// non-overlong 2-byte
		if( (0xC2 <= bytes[i] && bytes[i] <= 0xDF)
			&& (0x80 <= bytes[i+1] && bytes[i+1] <= 0xBF) ) {
			i += 2
			continue
		}
		;// excluding overlongs, straight 3-byte, excluding surrogates
		if( ( bytes[i] == 0xE0 && (0xA0 <= bytes[i+1] && bytes[i+1] <= 0xBF)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF) )
			|| ( ((0xE1 <= bytes[i] && bytes[i] <= 0xEC)
			|| bytes[i] == 0xEE || bytes[i] == 0xEF)
			&& (0x80 <= bytes[i+1] && bytes[i+1] <= 0xBF)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF) 	)
			|| ( bytes[i] == 0xED && (0x80 <= bytes[i+1] && bytes[i+1] <= 0x9F)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF) ) ) {
			i += 3
			continue
		}
		;// planes 1-3, planes 4-15, plane 16
		if( ( bytes[i] == 0xF0 && (0x90 <= bytes[i+1] && bytes[i+1] <= 0xBF)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF)
			&& (0x80 <= bytes[i+3] && bytes[i+3] <= 0xBF) )
			|| ( (0xF1 <= bytes[i] && bytes[i] <= 0xF3)
			&& (0x80 <= bytes[i+1] && bytes[i+1] <= 0xBF)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF)
			&& (0x80 <= bytes[i+3] && bytes[i+3] <= 0xBF) )
			|| ( bytes[i] == 0xF4 && (0x80 <= bytes[i+1] && bytes[i+1] <= 0x8F)
			&& (0x80 <= bytes[i+2] && bytes[i+2] <= 0xBF)
			&& (0x80 <= bytes[i+3] && bytes[i+3] <= 0xBF) ) ) {
			i += 4
			continue
		}
		t:=1
		break
	}
	
	if (t=0) ;the while-loop has no fails, then confirmed utf-8
		return 0
	;else do nothing and check again with the classic method below
	
	loop, %nbytes% {
		if (bytes[(A_Index-1)]<9) or (bytes[(A_Index-1)]>126)
			or ((bytes[(A_Index-1)]<32) and (bytes[(A_Index-1)]>13))
			return 1
	}
	
	return 0
}
JEE_StrUtf8BytesToText(ByRef vUtf8Bytes) {
	if A_IsUnicode
	{
		VarSetCapacity(vTemp, StrPut(vUtf8Bytes, "CP0"))
		StrPut(vUtf8Bytes, &vTemp, "CP0")
		return StrGet(&vTemp, "UTF-8")
	}
	else
		return StrGet(&vUtf8Bytes, "UTF-8")
}
eventHandler(wParam, lParam, msg, hwnd) {
	static WM_LBUTTONDOWN := 0x201
	, WM_LBUTTONUP := 0x202
	, WM_LBUTTONDBLCLK := 0x203
	, WM_CHAR := 0x102
	, lButtonDownTick := 0
	global clicktime:=0, generalbox, consolehwnd
	if (msg = WM_LBUTTONDOWN) {
		lButtonDownTick := A_TickCount
	} else if (msg = WM_LBUTTONUP) {
		clicktime := A_TickCount - lButtonDownTick
	} else if (hwnd = generalbox || hwnd = consolehwnd) && (msg = WM_LBUTTONDBLCLK) {
	    copy_log(hwnd,A_Gui)
	} else if (wParam = 1027) {
      Process, Exist 
      DetectHiddenWindows, On 
      if WinExist("Request ahk_class #32770 ahk_pid " . ErrorLevel) { 
         ControlSetText, Button1, &Select_FILE 
         ControlSetText, Button2, &Abort
      } 
   }
	return 
}
copy_log(hwnd,gui) {
   GuiControlGet, Prev, % gui ":", %hwnd%
	ToolTip, Copied log
	Clipboard := "", Clipboard := Prev
	SetTimer, RemoveToolTip, -1000
}
CountMatch(str, match) {
	_pos:=1,_total:=0,_with:=StrLen(match)
	while,(_pos:=InStr(str,match,,_pos))
	   _total++, _pos+=_with
    return _total
}
CreateZipFile(sZip) {
   ; Idea by shajul http://www.autohotkey.com/forum/viewtopic.php?t=65401
	; I just ensure the use of UTF-8-RAW to avoid UTF-8 BOM leading bytes corrupting the ZIP (BlassGO)
   global secure_user_info, HERE, TOOL
   if (secure_user_info && !(GetFullPathName(sZip) ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
      MsgBox, 262148, CreateZip preferences, % " Attempting to create a file outside of common paths:`n`n " sZip "`n`n Do you want to allow it?"
      IfMsgBox No
      {
         return 0
      }
   }
   FileDelete, % sZip
   FileEncoding, UTF-8-RAW
   Header1 := "PK" . Chr(5) . Chr(6)
	VarSetCapacity(Header2, 18, 0)
	file := FileOpen(sZip,"w")
	file.Write(Header1)
	file.RawWrite(Header2,18)
	file.close()
   return 1
} 
zip(FilesToZip,sZip) {
   ; Idea by shajul http://www.autohotkey.com/forum/viewtopic.php?t=65401
	; Improved by me (BlassGO)
   global general_log, secure_user_info, HERE, TOOL
   if InStr(FileExist(sZip), "A") {
      if (secure_user_info && !(GetFullPathName(sZip) ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
         MsgBox, 262148, Zip preferences, % " Attempting to edit file outside of common paths:`n`n " sZip "`n`n Do you want to allow it?"
         IfMsgBox No
         {
            return 0
         }
      }
   } else if !CreateZipFile(sZip) {
      return 0
   }
   try {
      psh := ComObjCreate( "Shell.Application")
      zip := psh.Namespace(sZip := GetFullPathName(sZip))
      Loop, parse, FilesToZip, `;
      {  
         to_zip:=A_LoopField
         if (_type:=FileExist(to_zip)){
            InStr(_type, "D") ? to_zip .= SubStr(to_zip,0)="\" ? "*.*" : "\*.*"
            Loop, Files, %to_zip%, DF
            {
               folder := psh.Namespace(dirname(A_LoopFileLongPath))
               name := basename(A_LoopFileLongPath)
               file_size := folder.ParseName(name).ExtendedProperty("Size")
               write_file("`nZIP: Adding """ name """ in """ sZip """`n", general_log)
               zip.CopyHere(A_LoopFileLongPath, 4|16)
               Loop {
                  for file in zip.Items()
                  {
                     if (file.Name=name) {
                        if (file.IsFolder||zip.ParseName(name).ExtendedProperty("Size")=file_size)
                           break 2
                        break
                     }
                  }
               }
            }
         } else {
            write_file("`nZIP: Cant find file or folder: """ to_zip """`n", general_log)
            return 0
         }
      }
   } catch e {
	   MsgBox, % 262144 + 16, Zip, % "A fatal error occurred:`n`n" e.message "`n`n--> " e.what
      return 0
	}
   return 1
}
unzip(sZip, sUnz, options := "-o", resolve := false) {
   ; Idea by shajul http://www.autohotkey.com/forum/viewtopic.php?t=65401
	; Improved by me (BlassGO)
   global general_log, secure_user_info, current, HERE, TOOL
	static zip_in_use, last_path
	if !sUnz
	   sUnz := A_ScriptDir
	if !resolve {
	    if (options ~= "i)\binside-zip\b") {
		   RegexMatch(sZip, "i)^(.*?\.zip)\K.*", back_relative)
		   RegexMatch(sZip, "i)^(.*?\.zip)", sZip)
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
		   return 0
		}
	}
	try {
		psh := ComObjCreate("Shell.Application")
		zip := psh.Namespace(sZip)
		back_opt := options
		if RegexMatch(options, "i)regex:\s*\K.*", regex) {
		   RegexMatch(options, "i)(.*?)(?=regex:)", options)
		} else if RegexMatch(options, "i)regex-name:\s*\K.*", regex) {
		   regex_name := true
		   RegexMatch(options, "i)(.*?)(?=regex-name:)", options)
		} else {
		   regex := ".*"
		}
		if (options ~= "i)\bfiles|-f\b")
		   allow_files := true
		if (options ~= "i)\bfolders|-d\b")
		   allow_folders := true
		if (options ~= "i)\boverwrite|force|-o\b")
		   overwrite := true
		if (options ~= "i)\bmix-path|-mix|-m\b")
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
					   file_size := file.ExtendedProperty("Size")
					   write_file("`nUNZIP: Extracting """ relative_to_zip """ in """ dest """`n", general_log)
					   folder.CopyHere(file, 4|16)
					   Loop {
						   if (FileExist(dest "\" file.Name) && (file.IsFolder||folder.ParseName(file.Name).ExtendedProperty("Size")=file_size)) {
							  break
						   }
					   }
					}
				}
			}
		}
	} catch e {
      InStr(e.what, "RegexMatch") ? e.message:="Check your Regex Pattern"
	   MsgBox, % 262144 + 16, Unzip, % "A fatal error occurred while extracting:`n""" zip_in_use """`n`n" e.message "`n`n--> " e.what
      return 0
	}
   (!resolve) ? (zip_in_use:="", last_path:="")
   return 1
}
check_content(options*) {
   global general_log
   if !InStr(FileExist(path:=GetFullPathName(options.Pop())), "A") {
      write_file("CANT FIND: " path, general_log)
      return 0
   }
   psh := ComObjCreate("Shell.Application")
   while options.MaxIndex() {
      relative_path:=options.RemoveAt(1), name:=basename(relative_path, false), exist:=false
      relative_path:=path . "\" . dirname(relative_path, false)
      try {
         if psh.Namespace(relative_path).ParseName(name) {
            exist:=true
         } else {
            break
         }
      } catch e {
         write_file("ZIP: A fatal error occurred while reading: """ relative_path """--> " e.message "--> " e.what, general_log)
         return 0
      }
   }
   return exist
}
FileDeleteZip(options*) {
   global general_log, secure_user_info, HERE, TOOL
   if !InStr(FileExist(path:=GetFullPathName(options.Pop())), "A") {
      write_file("CANT FIND: " path, general_log)
      return 0
   }
   if secure_user_info && !(path ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))") {
      MsgBox, 262148, Unzip preferences, % " Attempting to delete a file from:`n`n " path "`n`n Do you want to allow it?"
      IfMsgBox No
      {
         return 0
      }
   }
   psh := ComObjCreate("Shell.Application")
   dest := current "\tmp\FileDeleteZip"
   FileCreateDir, % dest
   folder := psh.Namespace(dest)
   while options.MaxIndex() {
      relative_path:=options.RemoveAt(1), name:=basename(relative_path, false)
      relative_path:=path . "\" . dirname(relative_path, false)
      try {
         if (file:=psh.Namespace(relative_path).ParseName(name)) {
            relative_to_zip := StrReplace(file.Path, path "\")
            file_size:=file.ExtendedProperty("Size")
            write_file("`nUNZIP: Deleting """ relative_to_zip """`n", general_log)
            folder.MoveHere(file, 4|16)
            Loop {
               if (FileExist(dest "\" file.Name) && (file.IsFolder||folder.ParseName(file.Name).ExtendedProperty("Size")=file_size)) {
                  break
               }
            }
            FileDelete, % dest "\" name
         } else {
            write_file("UNZIP: CANT FIND CONTENT: " name " in--> " relative_path, general_log)
            return 0
         }
      } catch e {
         write_file("UNZIP: A fatal error occurred while reading: """ relative_path """--> " e.message "--> " e.what, general_log)
         return 0
      }
   }
   FileRemoveDir, % dest, 1
   return exist
}
FileMoveZip(file,dest,zip) {
   global general_log, secure_user_info, HERE, TOOL
   if !InStr(FileExist(path:=GetFullPathName(zip)), "A") {
      write_file("CANT FIND: " path, general_log)
      return 0
   }
   psh := ComObjCreate("Shell.Application")
   name:=basename(file, false)
   relative_path:=path . "\" . dirname(file, false)
   if (secure_user_info) {
      if !(GetFullPathName(dest) ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))") {
         MsgBox, 262148, Unzip preferences, % " Attempting to extracting outside of common paths:`n`n " dest "`n`n Do you want to allow it?"
         IfMsgBox No
         {
            return 0
         }
      }
      if !(path ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))") {
         MsgBox, 262148, Unzip preferences, % " Attempting to move a file from:`n`n " path "`n`n Do you want to allow it?"
         IfMsgBox No
         {
            return 0
         }
      }
   }
   try {
      if (file:=psh.Namespace(relative_path).ParseName(name)) {
         if !InStr(FileExist(dest), "D")
            FileCreateDir, % dest
         relative_to_zip := StrReplace(file.Path, path "\")
         folder:=psh.Namespace(GetFullPathName(dest))
         file_size:=file.ExtendedProperty("Size")
         write_file("`nUNZIP: Moving """ relative_to_zip """ to """ dest """`n", general_log)
         folder.MoveHere(file, 4|16)
         Loop {
            if (FileExist(dest "\" file.Name) && (file.IsFolder||folder.ParseName(file.Name).ExtendedProperty("Size")=file_size)) {
               break
            }
         }
      } else {
         write_file("UNZIP: CANT FIND CONTENT: " name " in--> " relative_path, general_log)
         return 0
      }
   } catch e {
      write_file("UNZIP: A fatal error occurred while reading: """ relative_path """--> " e.message "--> " e.what, general_log)
      return 0
   }
   return 1
}
extract(file,dest,zip:="") {
   global CONFIG, general_log, secure_user_info, HERE, TOOL
   if CONFIG||zip {
      if !InStr(FileExist(path:=GetFullPathName(CONFIG ? CONFIG : zip)), "A") {
         write_file("CANT FIND: " path, general_log)
         return 0
      }
      psh := ComObjCreate("Shell.Application")
      name:=basename(file, false)
      relative_path:=path . "\" . dirname(file, false)
      if (secure_user_info && !(GetFullPathName(dest) ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
         MsgBox, 262148, Unzip preferences, % " Attempting to extracting outside of common paths:`n`n " dest "`n`n Do you want to allow it?"
         IfMsgBox No
         {
            return 0
         }
      }
      try {
         if (file:=psh.Namespace(relative_path).ParseName(name)) {
            if !InStr(FileExist(dest), "D")
               FileCreateDir, % dest
            relative_to_zip := StrReplace(file.Path, path "\")
            folder:=psh.Namespace(GetFullPathName(dest))
            file_size:=file.ExtendedProperty("Size")
            write_file("`nUNZIP: Extracting """ relative_to_zip """ in """ dest """`n", general_log)
            folder.CopyHere(file, 4|16)
            Loop {
               if (FileExist(dest "\" file.Name) && (file.IsFolder||folder.ParseName(file.Name).ExtendedProperty("Size")=file_size)) {
                  break
               }
            }
         } else {
            write_file("UNZIP: CANT FIND CONTENT: " name " in--> " relative_path, general_log)
            return 0
         }
      } catch e {
         write_file("UNZIP: A fatal error occurred while reading: """ relative_path """--> " e.message "--> " e.what, general_log)
         return 0
      }
      return 1
   } else {
      return 0
   }
}
on_install(zip,checked:=false) {
   global secure_user_info, current, anti_notspam, CONFIG
   if !(checked||check_content("on_install.config",zip))
      return 0
   CONFIG:=zip, tmp:=current "\tmp"
   FileRemoveDir, % tmp, 1
   extract("on_install.config",tmp)
   if load_config(read_file(tmp "\on_install.config"),,,,,true) {
      result:=1
   } else {
      print(">> " basename(zip) " stopped!")
      result:=0
   }
   FileDelete, % tmp "\on_install.config"
   secure_user_info:=false, anti_notspam:=false
   return result
}
ensure_java(txt:="java version") {
   static passed
   if passed||InStr(run_cmd("java -version"),txt) {
      passed:=true
      return 1
   } else if question("Java","JAVA not detected`n`nDo you want to go to the official site?") {
      gotolink("https://www.java.com/en/")
   }
   unexpected:="Java not available"
   print(">> " unexpected)
   return 0
}
apktool(options*) {
   global apktool
   if !ensure_java()
      return 0
   return run_cmd("java -jar """ apktool """ " StrJoin(options,A_Space,true))
}
sign(options*) {
   global sign
   if !ensure_java()
      return 0
   return run_cmd("java -jar """ sign """ " StrJoin(options,A_Space,true))
}
zipalign(options*) {
   global zipalign
   return run_cmd("""" zipalign """ " StrJoin(options,A_Space,true))
}
7za(options*) {
   global 7za
   return run_cmd("""" 7za """ " StrJoin(options,A_Space,true))
}
run_cmd_literal(options*) {
   return run_cmd(options.RemoveAt(1) . " " . StrJoin(options,A_Space,true))
}
shell_literal(options*) {
   return shell(StrJoin(options,A_Space,true))
}
ls(options*) {
   restore:=[]
   while options.MaxIndex() {
      if (SubStr(options[1],1,1)="-") {
         switch (options.RemoveAt(1)) {
            case "-files","-f":
               mode.="F"
            case "-dirs","-d":
               mode.="D"
            case "-recursive","-r":
               mode.="R"
            case "-pattern","-p":
               pattern:=true
         }
      } else {
         restore.Push(options.RemoveAt(1))
      }
   }
   (restore.MaxIndex()) ? (options:=restore, restore:="") : options:={1: A_ScriptDir}
   for cont, path in options
   {
      (!pattern) ? InStr(FileExist(path), "D") ? path .= SubStr(path,0)="\" ? "*.*" : "\*.*"
      Loop, Files, %path%, %mode%
      {
         (files) ? files.="`n"
         files.=A_LoopFileLongPath
      }
   }
   return files
}
smali_kit(options*) {
   complete_extract:=true, result:=0, to_do:={}, file_info:={}
   while options.MaxIndex() {
      if (SubStr(p:=options.RemoveAt(1),1,1)="-") {
         (SubStr(options[1],1,1)!="-") ? ((p2:=options.RemoveAt(1)) ? (SubStr(options[1],1,1)!="-") ? (p3:=options.RemoveAt(1)) : p3:="") : (p2:=p3:="")
         switch (p) {
            case "-dir","-d","-file","-f":
               dir:=p2
            case "-method","-m":
              method:=p2
            case "-print-path","-pp":
              print:=true, result:=""
            case "-replace","-r":
              to_do:={1: {rpl:p2, r:true}}
            case "-delete-method","-dm":
              to_do:={1: {rpl:"", r:true}}
            case "-remake","-re":
              to_do:={1: {rpl:p2, r:true}}, complete_extract:=false
            case "-replace-in-method","-rim":
              to_do.Push({orig:p2, rpl:p3}), complete_extract:=false
            case "-delete-in-method","-dim":
              to_do.Push({orig:p2}), complete_extract:=false
            case "-after-line","-al":
              to_do.Push({line:p2, add:p3, al:true}), complete_extract:=false
            case "-before-line","-bl":
              to_do.Push({line:p2, add:p3, bl:true}), complete_extract:=false
            case "-name","-n":
              opt.="name: " p2 " "
            case "-static-name","-sn":
              opt.="static-name: " p2 " "
            case "-check","-c":
              check:=true
         }
      }
   }
   (dir&&method) ? info:=StrSplit(find_str(dir,method,".end method",opt "complete_extract recursive all lines info"),"`n")
   Loop % info.MaxIndex()
   {
      if InStr(info[A_Index], "PATH=") {
         path:=SubStr(info[A_Index],StrLen("PATH=")+1), pos:=SubStr(info[A_Index+1],StrLen("POS=")+1), len:=SubStr(info[A_Index+2],StrLen("LEN=")+1)
         content:=read_file(path)
         check_method:=SubStr(content,pos,30)
         if (check_method~="^\.method ")&&!(check_method~="\.method abstract|\.method public abstract") {
            content:=SubStr(content, pos, len)
            file_info.Push({path:path, content:(complete_extract) ? content : RegExReplace(content, "s)^[^\r?\n]*\r?\n(.*)(?:\r?\n.*$)", "$1")})
         }
         content:=""
      }
   }
   info:=""
   for cont, file in file_info
   {
      if print {
         (result) ? result.="`n"
         result.=file.path
         continue
      }
      content:=file.content
      for cont2, props in to_do
      {
         if props.r {
            content:=props.rpl
         } else if props.orig {
            content:=StrReplace(content, props.orig, props.rpl)
         } else if props.line {
            content:=StrReplace((props.bl) ? RegExReplace(content, "`am)^(.*\Q" . props.line . "\E(?:.*)(?=$))(?:\r?\n)*(.*)$", "$1`n``~smali_kit~```n$2") : RegExReplace(content, "`am)(^|.*)(?:\r?\n)*([^\r\n]*\Q" . props.line . "\E.*)$", "$1`n``~smali_kit~```n$2"), "``~smali_kit~``", props.add)
         }
      }
      content:=StrReplace(content_tmp:=read_file(file.path),file.content,content)
      if (content=content_tmp) {
         (check) ? print(">> Nothing: """ . file.path . """")
      } else {
         FileDelete(file.path)
         if write_file(content,file.path) {
            result:=1, (check) ? print(">> Edited: """ . file.path . """")
         }
      }
      content:=content_tmp:=""
   }
   return result
}
find_str(path,str,str2:="",options:="") {
   ; By @BlassGO
   orig_len:=StrLen(str), orig_len2:=StrLen(str2)
   RegexMatch(options, "i)encoding:\s*(.*)(?=\w+:|$)", opt) ? options:=StrReplace(options, opt)
   enc:=opt1 ? Trim(opt1) : "UTF-8"
   if RegexMatch(options, "i)name:\s*(.*)(?=\w+:|$)", opt)
      options:=StrReplace(options, opt), name:=opt1 ? Trim(opt1) : "", literal_name:=false
   else if RegexMatch(options, "i)static-name:\s*(.*)(?=\w+:|$)", opt) 
      options:=StrReplace(options, opt), name:=opt1 ? Trim(opt1) : "", literal_name:=true
   FileEncoding, % enc
   if (options ~= "i)\bpattern\b")
		pattern := true
   if (options ~= "i)\ball\b")
		all := true
   if (options ~= "i)\binfo\b")
		info := true
   if (options ~= "i)\brecursive\b")
		mode := "R"
   if (options ~= "i)\blines\b")
		as_lines := true
   if (options ~= "i)\bextract\b")
		extract := true, header:=false
   if (options ~= "i)\bcomplete_extract\b")
		extract := true, header:=true
   (!pattern) ? InStr(FileExist(path), "D") ? path .= SubStr(path,0)="\" ? "*.*" : "\*.*"
   Loop, Files, %path%, %mode%
   {  
      if isBinFile(A_LoopFileLongPath)||(name && !((literal_name&&name=A_LoopFileName)||(!literal_name&&InStr(A_LoopFileName,name))))
         continue
      _last:=1
      FileRead, content, % A_LoopFileLongPath
      as_lines ? tlen:=StrLen(content)
      while (_last>0) {
         len:=orig_len, len2:=orig_len2
         if (_at:=InStr(content,str,,_last)) {
            if as_lines {
               (_startline:=InStr(content,"`n",,_at-tlen)) ? (len+=(_at-_startline)-1, _at:=_startline+1) : (_at:=RegExMatch(content, "P)[^\r\n]+", len))
               RegExMatch(content, "P)(?:.*)(?=\r?\n|$)", line, _at+len) ? len+=line
            }
            if str2 {
               if (_at2:=InStr(content,str2,,_at+len)) {
                  if as_lines {
                     (_startline:=InStr(content,"`n",,_at2-tlen)) ? (len2+=(_at2-_startline)-1, _at2:=_startline+1) : (_at2:=RegExMatch(content, "P)[^\r\n]+", len2))
                     RegExMatch(content, "P)(?:.*)(?=\r?\n|$)", line, _at2+len2) ? len2+=line
                  }
                  (extract) ? _last:=_at2+len2 : _last:=0
                  if info {
                     if all
                        result ? result.="`n" : false, result.= header ? ("PATH=" . A_LoopFileLongPath . "`nPOS=" . _at . "`nLEN=" . (_at2-_at)+len2) : ("PATH=" . A_LoopFileLongPath . "`nPOS=" . _at+len . "`nLEN=" . (_at2-_at)-len)
                     else
                        return header ? ("PATH=" . A_LoopFileLongPath . "`nPOS=" . _at . "`nLEN=" . (_at2-_at)+len2) : ("PATH=" . A_LoopFileLongPath . "`nPOS=" . _at+len . "`nLEN=" . (_at2-_at)-len)
                  } else if all {
                     result ? result.="`n" : false, result.=(extract) ? (header ? SubStr(content,_at,(_at2-_at)+len2) : SubStr(content,_at+len,(_at2-_at)-len)) : A_LoopFileLongPath
                  } else {
                     return (extract) ? (header ? SubStr(content,_at,(_at2-_at)+len2) : SubStr(content,_at+len,(_at2-_at)-len)) : A_LoopFileLongPath
                  }
               } else {
                  _last:=0
               }
            } else {
               if extract {
                  (!as_lines) ? RegExMatch(content, "P)(?:.*)(?=\r?\n|$)", line, _at+len) ? len+=line
                  _last:=_at+len
               } else {
                  _last:=0
               }
               if info {
                  if all
                     result ? result.="`n" : false, result.="PATH=" . A_LoopFileLongPath . "`nPOS=" . _at . "`nLEN=" . len
                  else
                     return "PATH=" . A_LoopFileLongPath . "`nPOS=" . _at . "`nLEN=" . len
               } else if all {
                  result ? result.="`n" : false, result.=(extract) ? SubStr(content,_at,len) : A_LoopFileLongPath
               } else {
                  return (extract) ? SubStr(content,_at,len) : A_LoopFileLongPath
               }
            }
         } else {
            _last:=0
         }
      }
   }
   return result
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
format_sh(str){
   return RegExReplace(RegExReplace(RegExReplace(str,"m`a)^\s+|\h+$|\s+(?-m)$"), "(if|do|then|else|elif|\{|\()[ \t]*\r?\n", "$1 "), "(;[ \t]*\r?\n)|(\r?\n)", ";")
}
sh(str, noroot:="", noescape:="") {
   return adb_shell(format_sh(str),noroot,noescape)
}
shell(action, noroot := "", noescape := "") {
   return RegExReplace(adb_shell(action, noroot, noescape), "m`a)^\s+|\h+$|\s+(?-m)$")
}
check_string(try, str, files := true) {
	(files&&InStr(FileExist(try), "A")) ? try := read_file(try)
	return (try ~= str)
}
FileCreateDir(options*) {
   global HERE, TOOL, secure_user_info, general_log
   for key,dir in options {
      GetFullPathName(dir) ? dir := GetFullPathName(dir)
      (A_Index=1) ? result:=1
      if (secure_user_info && !(dir ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
         MsgBox, 262148, Write preferences, % " Attempting to create a directory outside of common paths:`n`n " dir "`n`n Do you want to allow it?"
         IfMsgBox No
         {
            return 0
         }
      }
      if !InStr(FileExist(dir), "D")
         FileCreateDir, % dir
      (!InStr(FileExist(dir), "D")) ? result:=0
   }
   return result
}
FileDelete(options*) {
   global HERE, TOOL, secure_user_info, general_log
   for key,dir in options {
      dir := GetFullPathName(dir)
      if (secure_user_info && !(dir ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
         MsgBox, 262148, Removal preferences, % " Attempting to delete a file outside of common paths:`n`n " dir "`n`n Do you want to allow it?"
         IfMsgBox No
         {
            return 0
         }
      }
      _type:=FileExist(dir)
      if InStr(_type, "A")
         FileDelete, % dir
      else if InStr(_type, "D")
         FileRemoveDir, % dir, 1
   }
   return 1
}
FileMove(orig,dir) {
   global HERE, TOOL, secure_user_info, general_log
   GetFullPathName(dir) ? dir := GetFullPathName(dir)
   orig := GetFullPathName(orig)
   if (secure_user_info) {
      if !(dir ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))") {
         MsgBox, 262148, Move preferences, % " Attempting to move a file outside of common paths:`n`n " dir "`n`n Do you want to allow it?"
         IfMsgBox No
         {
            return 0
         }
      }
      if !(orig ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))") {
         MsgBox, 262148, Move preferences, % " Attempting to move a file from:`n`n " orig "`n`n Do you want to allow it?"
         IfMsgBox No
         {
            return 0
         }
      }
   }
   FileMove, % orig, % dir, 1
   return FileExist(dir)
}
FileSelectFile(title:="",filter:="",rootdir:="",options:="") {
   try {
      FileSelectFile, result, % options, % rootdir, % title, % filter
   } catch {
      return 0
   }
   return result
}
FileSelectFolder(prompt:="",rootdir:="",options:="") {
   try {
      FileSelectFolder, result, % rootdir, % options, % prompt
   } catch {
      return 0
   }
   return result
}
write_file(content, file, enc := "UTF-8") {
   global HERE, TOOL, secure_user_info, general_log, current
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
   try {
     if !InStr(FileExist(dest:=dirname(file)), "D")
        FileCreateDir, % dest
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
   global secure_user_info, current, tools, extras, exitcode, cmdpid
   static allowed_actions
   (!allowed_actions) ? allowed_actions := tools "\adb.exe," . tools "\fastboot.exe," . "java -version," . "java -jar """ tools "\apktool.jar""," . "java -jar """ tools "\sign.jar""," . tools "\zipalign.exe," . tools "\7za.exe,"
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
	  }
   }
   DetectHiddenWindows, On
   Run, %comspec% /k,, Hide, cmdpid
   WinWait, ahk_pid %cmdpid%
   DllCall("AttachConsole", "UInt", cmdpid)
   shell:=comobjcreate("wscript.shell"), exec:=(shell.exec(comspec . " /c """ . code . " 2>&1"""))
   if (seconds ~= "^[1-9][0-9]*$") {
	   SetTimer, cmd_output, % seconds * 1000
	   While (!exec.Status)
	   {
		  Sleep, 100
	   }
	   exitcode:=exec.ExitCode
	   SetTimer, cmd_output, Off
   }
   (result="") ? result:=exec.stdout.readall()
	(exitcode="") ? exitcode:=exec.ExitCode
   Process, Exist, % cmdpid
   if ErrorLevel {
      DllCall("FreeConsole")
      exec.StdOut.Close(),exec.StdErr.Close(),exec.StdIn.Close(),exec.Terminate()
      Process, Close, % cmdpid
   }
   return JEE_StrUtf8BytesToText(result),cmdpid:=""
   cmd_output:
   if (exitcode="") {
      result:=(exec.Status=1)?exec.stdout.readall():0
      DllCall("FreeConsole")
	   exec.StdOut.Close(),exec.StdErr.Close(),exec.StdIn.Close(),exec.Terminate()
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
   return run_cmd("""" adb """" " " action, seconds)
}
adb_serial(action, this_serial := "", seconds:="") {
   global serial
   return (this_serial) ? adb("-s " this_serial " " action, seconds) : ((serial) ? adb("-s " serial " " action, seconds) : 0)
}
adb_shell(action, noroot := "", noescape := "") {
   global PATH
   (!noescape) ? action := StrReplace(action, "\", "\\")
   action := StrReplace("export PATH=""$PATH:" . PATH . """;" . StrReplace(action, "`r`n"), """", "\""")
   ensure_shell()
   return (!noroot&&InStr(adb_serial("shell ""[ -e \""$(command -v su)\"" ] && echo SU command support"""), "SU command")) ? adb_serial("shell ""su -c '" . action . "'""") : adb_serial("shell """ . action . """")
}
ensure_shell() {
   global adb, exist_device, device_mode, remember_mode, general_log, serial
   while !InStr(adb_serial("shell echo pwu"), "pwu")
   {
      if !attemps {
	     print(">> Waiting device shell")
		  attemps := true
	   }
      (!(serial&&check_active(serial))) ? find_device(1)
   }
}
fastboot(action, seconds := "") {
   global fastboot
   Process, Close, % basename(fastboot)
   return run_cmd("""" fastboot """" " " action, seconds)
}
fastboot_serial(action, this_serial := "", seconds:="") {
   global serial
   return (this_serial) ? fastboot("-s " this_serial " " action, seconds) : ((serial) ? fastboot("-s " serial " " action, seconds) : 0)
}
is_active(serial) {
   global exist_device, device_mode, remember_mode
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
   global device_mode, exist_device, unlocked, fastbootd, secure, current_slot, super, serial, current_anti, native_parts, general_log
   unlocked =
   fastbootd =
   secure =
   current_slot =
   current_anti =
   super =
   if (serial && !check_active(serial))
      return 0
   if (device_mode!="fastboot")
      return 0
   get := fastboot_serial("getvar all")
   if !get
      return 0
   native_parts := {}
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
            try {
               native_parts.HasKey(huh[A_Index+1]) ? native_parts[huh[A_Index+1]].is_logical:=true : native_parts[huh[A_Index+1]]:={is_logical:true}
            } catch e {
               write_file("`nAbnormal partition: " . huh[A_Index+1] . "-->" . e.message . "`n",general_log)
            }
			}
	    }
		If (huh[A_Index]="partition-size") {
		   raw := huh[A_Index+2]
			SetFormat, Integer, D
			raw += 0
			if raw is integer
			{
            try {
               native_parts.HasKey(huh[A_Index+1]) ? native_parts[huh[A_Index+1]].size:=raw : native_parts[huh[A_Index+1]]:={size:raw}
               if (huh[A_Index+1] ~= "^(system|system_ext|vendor|product|odm)(_a|_b)$") && !native_parts[huh[A_Index+1]].is_logical {
                  super:=true
                  native_parts[huh[A_Index+1]].is_logical:=true
               } else if !super && (huh[A_Index+1]="super") {
                  super:=true
               }
            } catch e {
               write_file("`nAbnormal partition: " . huh[A_Index+1] . "-->" . e.message . "`n",general_log)
            }
			}
	    }
   }  
}
is_logical(part) {
   global native_parts
   return native_parts.HasKey(part) ? native_parts[part].is_logical : false
}
is_real(part) {
   global native_parts
   return native_parts.HasKey(part) 
}
get_size(part) {
   global native_parts
   return native_parts.HasKey(part) ? native_parts[part].size : false
}
free_logical(){
   global super
   global native_parts
   if !super
      return 0
   get_bootloader_env()
   subpart_size := 0, free_logical := 0, subpart_count:=0
   if !(super_size := get_size("super")) {
      print(">> Empty SUPER image!")
      return
   }
   for part, props in native_parts
       (props.is_logical) ? (subpart_count++, subpart_size+=props.size)
   if (super_size>subpart_size) {
       ; 1MB reserved for each subpart
       free_logical := (super_size - 1048576 * subpart_count) - subpart_size
   } else {
      print(">> Abnormal SUPER image!")
   }
   return (free_logical>0) ? free_logical : 0
}
check_free_space(img, part) {
   global mx, my, style, native_parts, dummy_img, super, need, start, partcontrol, free_logical, serial, HeaderColors
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
   Gui 2: Destroy 
   Gui 2: Default 
   Gui 2: +AlwaysOnTop
   Gui 2: margin, %mx%, %my%
   Gui 2: Font, s10, %style%
   Gui 2: Add, Text, AltSubmit Y+0 c254EC5 vneed, % "You need " . normal_units(needed)
   Gui 2: Add, ListView, AltSubmit NoSortHdr -LV0x10 LV0x20 Checked gpartcontrol vpartcontrol hwndpartcontrol XS Y+10, |Partition to remove|Size
   Gui 2: Add, Button, AltSubmit center XS Y+10 h20 w100 vstart gstart, START
   LV_Delete()
   for part2, props in native_parts {
       if props.is_logical {
          if (part2=part)
             continue
          if (props.size<=0)
	          continue
          LV_Add("", "", part2, normal_units(props.size))
       }
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
      MsgBox, % 262144 + 64, HELP, There is not enough space yet!
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
optimize() {
   global cache, serial, general_log
   if (serial && !check_active(serial))
      return
   (!IsObject(cache)) ? cache:={commands:{}, parts:{}}
   Loop, parse, % adb_shell("ls -lR /dev/block 2>dev/null"), `n,`r 
   {
      if (chr:=SubStr(A_LoopField,1,1)) {
         if (chr="/") {
            dir:=Trim(A_LoopField,A_Space "`t:")
         } else if (chr~="^b|c|l$") {
            try {
               data:=StrSplit(Trim(A_LoopField,A_Space "`t"), A_Space)
               (chr="l") ? cache.parts[data[data.MaxIndex()-2]]:=data.Pop() : cache.parts[data[data.MaxIndex()]]:=dir "/" data.Pop()
               data:=""
            } catch e {
                write_file("`nCACHE: " e.message " -> " A_LoopField "`n",general_log)
            }
         }
      }
   }
   Loop, parse, % adb_shell("IFS="":""; for dir in $PATH; do echo $dir; ls -l $dir 2>/dev/null; done"), `n,`r 
   {
      if (chr:=SubStr(A_LoopField,1,1)) {
         if (chr="/") {
            dir:=Trim(A_LoopField,A_Space "`t")
         } else if (chr~="^-|l$") {
            try {
               data:=StrSplit(Trim(A_LoopField,A_Space "`t"), A_Space)
               if (chr="l") {
                  name:=data[data.MaxIndex()-2]
               } else {
                  name:=data.Pop()
                  (SubStr(name,0)="*") ? name:=SubStr(name,1,StrLen(name)-1)
               }
               (!(cache.commands.HasKey(name)||InStr(name,"/"))) ? cache.commands[name]:=dir "/" name
               data:=""
            } catch e {
                write_file("`nCACHE: " e.message " -> " A_LoopField "`n",general_log)
            }
         }
      }
   }
   return 1
}
find_device(attemps := 1, show_msg := "", show_box := "", show_panel := "") {
   global exist_device, device_mode, device_connection, remember_mode, currentdevice, devices, serial, current, cache
   global wireless_IP, wireless_PORT, hidden_devices, wireless_FORCE
   global style, adb, mx, my, general_log, HeaderColors, ip_check
   exist_device=
   device_mode=
   device_connection=
   serial_n=0
   remember_mode=
   cache=
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
					 MsgBox, % 262144 + 16, HELP, Could not start ADB server`n`nCannot continue...
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
					     MsgBox, % 262144 + 16, HELP, % "Invalid IP: """ wireless_IP """"
						 break
					  }
					  if !port {
						if (wireless_PORT ~= "^\d+$") {
						   port := wireless_PORT
						} else if wireless_PORT {
						   MsgBox, % 262144 + 16, HELP, % "Invalid PORT: """ wireless_PORT """"
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
             Gui new4: Destroy 
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
						       help(current "\images\unauthorized.png", "A device was detected, but access is denied!`n`nPlease fix it manually:`nYou can try turning USB debugging off and on.")
                         print(">> Warning: Unauthorized device!")
				             break
		                } else {
                        if (result ~= "\boffline\b") {
                           help(current "\images\turn_on.png", "A device was detected, but it is inactive!`n`nPlease Turn On the Screen of your device to restore the connection.")
                           print(">> Warning: Offline device!")
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
		         MsgBox, % 262144 + 64, HELP, % "HUH Can't connect TCP/IP: `n`nIP[" ip "] : PORT[" port "]"
			  } else {
			     MsgBox, % 262144 + 64, HELP, HUH Can't detect your device
			  }
		  }
		  break
	   }
   }
   if exist_device {
      if (device_mode="fastboot")
         get_bootloader_env()
      else {
         print(">> Optimizing: Please wait...")
         optimize()
         print(">> Optimizing: Done")
      }
      return serial
   } else {
      return 0
   }
   new4GuiClose:
   if !show_panel&&!currentdevice {
      MsgBox, % 262144 + 64, HELP, % "Double click the device you want"
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
      MsgBox, % 262144 + 64, HELP, You cant delete partitions from normal fastboot, only fastbootD
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
	  MsgBox, % 262144 + 64, HELP, You can only delete Dynamic Partitions
	  return 0
   }
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
      MsgBox, % 262144 + 16, ERROR, % result
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
      MsgBox, % 262144 + 64, HELP, You cant create partitions from normal fastboot, only fastbootD
	  return 0
   }
   if !super {
      print(">> No dynamic device")
	  MsgBox, % 262144 + 64, HELP, You can only create partitions on devices with Dynamic Partitions
	  return 0
   }
   if !size
      return 0
   print(">> Creating " part "...")
   result := fastboot("create-logical-partition " part " " size " -s " serial)
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
      MsgBox, % 262144 + 16, ERROR, % result
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
file_manager(from:="/sdcard") {
   global mx, my, style, explorer_list, to_find_exp, explorer_findhwnd, explorer, explorer_back, explorer_view, explorer_delete, explorer_export, current, guiexplorer, general_log, current_path, cache, exppermUID, exppermGID, exppermPERM, exppermCONTEXT, UID, GID, PERM, FCONTEXT
   if !IsObject(cache)
      optimize()
	if !cache.commands.HasKey("ls") {
      MsgBox, % 262144 + 16, ERROR, file_manager: The "ls" command do not exist on the device
      return 0
   }
   if !(cache.commands.HasKey("rm")&&cache.commands.HasKey("mv")&&cache.commands.HasKey("cp")&&cache.commands.HasKey("chown")&&cache.commands.HasKey("chmod")&&cache.commands.HasKey("chcon")) {
      MsgBox, % 262144 + 16, ERROR, file_manager: Some commands do not exist on the device, you may experience problems
   }
   Menu, MenuExp, Add, Delete, explorer_delete
	Menu, MenuExp, Add, Export, explorer_export
   Menu, MenuExp, Add, Permissions, explorer_permissions
   Gui exp: New 
   Gui exp: Default 
   Gui exp: +AlwaysOnTop +Resize +Hwndguiexplorer
   Gui exp: margin, %mx%, %my%
   Gui exp: Font, s10, %style%
   Gui exp: Add, Edit, w390 hwndexplorer_findhwnd vto_find_exp gexplorer_find Section,
   Gui exp: Add, Picture, center X+0 YP w30 h30 vexplorer_back gexplorer_back, % current . "\images\back.png"
   Gui exp: Add, Picture, center X+0 YP w30 h30 vexplorer_view gexplorer_view, % current . "\images\view.png"
   Gui exp: Add, Picture, center X+0 YP w30 h30 vexplorer_delete gexplorer_delete, % current . "\images\delete.png"
   Gui exp: Add, Picture, center X+0 YP w30 h30 vexplorer_export gexplorer_export, % current . "\images\export.png"
   Gui exp: Add, Edit, w390 vcurrent_path XS Y+0 Center, %from%
   Gui exp: Add, Button, Hidden +Default w0 h0 gupdate_path, SET
   Gui exp: Add, ListView, AltSubmit +Multi -ReadOnly hwndexplorer NoSortHdr Sort -LV0x10 LV0x20 gexplorer_list vexplorer_list XS Y+0 w520 h400, Name|In Folder|Type
   gosub explorer_load
   Gui exp: show, AutoSize Center, File Manager
   Gui exp: +LastFound
   SetEditCueBanner(explorer_findhwnd, "Search by name...")
   ControlFocus, current_path, ahk_class AutoHotkeyGUI 
   WinWaitClose
   return tree
   expGuiClose:
      Gui exp: Destroy
      return
   expGuiSize:
      if (A_EventInfo = 1)
         return
      AutoXYWH("w", "to_find_exp", "current_path"), AutoXYWH("x", "explorer_back", "explorer_view", "explorer_delete", "explorer_export"), AutoXYWH("wh", explorer)
   return
   update_path:
      Gui exp: Submit, NoHide
      if current_path {
         from:=current_path
         goto explorer_load
      }
   return
   explorer_back:
      from:=(from="/") ? from : dirname(from)
      (!from) ? from:="/"
      goto explorer_load
   return
   explorer_view:
      if list_mode {
         GuiControl, exp:+Report, explorer_list
      } else {
         GuiControl, exp:+Icon, explorer_list
      }
      list_mode:=!list_mode
   return
   explorer_delete:
      Gui exp: Default 
      command:=""
      for select in selected
      {
         LV_GetText(name, select, 1)
         (A_Index=1) ? command.="("
         command.="rm -rf """ . dir . name """; "
      }
      if command {
         command.=") 2>/dev/null"
         ToolTip, % "Deleting " . selected.Count() . " contents..."
         write_file("`n(" . command . ") -> (" . adb_shell(command) . ")`n", general_log)
         SetTimer, RemoveToolTip, -100
         goto explorer_load
      }
   return
   explorer_permissions:
      Gui exp: Default 
      if selected.Count() {
         Gui exp: -AlwaysOnTop
         Gui expperm: New 
         Gui expperm: +AlwaysOnTop
         Gui expperm: margin, %mx%, %my%
         Gui expperm: Font, s10, %style%
         Gui expperm: Add, Text, Section, set_perm 
         Gui expperm: Add, Edit, X+5 YP w100 hwndexppermUID vUID Center,
         Gui expperm: Add, Edit, X+5 YP w100 hwndexppermGID vGID Center,
         Gui expperm: Add, Edit, X+5 YP w100 hwndexppermPERM vPERM Center,
         Gui expperm: Add, Text, XS Y+5 Section, set_context 
         Gui expperm: Add, Edit, X+5 YP w200 hwndexppermCONTEXT vFCONTEXT Center,
         Gui expperm: Add, Button, XS+80 Y+5 w200 Center gexppermAPPLY, APPLY
         Gui expperm: show, AutoSize Center, Set Permissions
         SetEditCueBanner(exppermUID, "User ID: 0"), SetEditCueBanner(exppermGID, "Group ID: 0"), SetEditCueBanner(exppermPERM, "MODE: 0755"), SetEditCueBanner(exppermCONTEXT, "u:object_r:system_file:s0")
         WinWaitClose, Set Permissions
         return
      }
      Gui exp: +LastFound
   exppermGuiClose:
      Gui expperm: Destroy
   return
   exppermAPPLY:
      Gui expperm: Submit, NoHide
      Gui expperm: Destroy
      Gui exp: Default 
      command:=""
      if UID||GID||PERM||FCONTEXT {
         UID:=Trim(UID), GID:=Trim(GID), PERM:=Trim(PERM), FCONTEXT:=Trim(FCONTEXT)
         for select in selected
         {
            LV_GetText(name, select, 1)
            (A_Index=1) ? command.="("
            (UID!=""&&GID!="") ? command.="chown " . UID . ":" . GID  " """ . dir . name """ || chown " . UID . "." . GID  " """ . dir . name """; "
            (PERM!="") ? command.="chmod " . PERM .  " """ . dir . name """; "
            (FCONTEXT!="") ? command.="chcon -h " . FCONTEXT .  " """ . dir . name """ || chcon " . FCONTEXT .  " """ . dir . name """; "
         }
      }
      if command {
         command.=") 2>/dev/null"
         ToolTip, % "Setting permissions for " . selected.Count() . " contents..."
         write_file("`n(" . command . ") -> (" . adb_shell(command) . ")`n", general_log)
         SetTimer, RemoveToolTip, -100
         selected:={}
      }
   return
   explorer_export:
      if (count:=selected.Count()) {
         Gui exp: Default 
         Gui exp: -AlwaysOnTop
         if open {
            to:=open
         } else {
            FileSelectFolder, to, , , Select the destination folder:
         }
         if to {
            TMP:=""
            ToolTip, % "Exporting " . count . " contents..."
            for select in selected
            {
               LV_GetText(name, select, 1)
               if (dir~="^/sdcard") {
                  command:="pull """ . dir . name """ """ . to . """"
               } else {
                  TMP:=ensure_tmp()
                  if !TMP
                     return
                  command:="cp -rf """ . dir . name """ """ . TMP . """"
                  write_file("`n(" . command . ") -> (" . adb_shell(command) . ")`n", general_log)
                  command:="pull """ . TMP . "/" . name """ """ . to . """"
               }
               write_file("`nADB -> (" . command . ") -> (" . adb_serial(command) . ")`n", general_log)
               if TMP {
                  command:="rm -rf """ . TMP . "/" . name """"
                  write_file("`n(" . command . ") -> (" . adb_shell(command) . ")`n", general_log)
               }
            }
            SetTimer, RemoveToolTip, -100
            if open {
               open_dest:=to . "\" . name
               Run, "%open_dest%"
            } else {
               Run, "%to%"
            }
            selected:={}
         }
      }
   return
   expGuiDropFiles:
   ToolTip, Loading files...
   TMP:=""
   if !(from~="^/sdcard") {
      TMP:=ensure_tmp()
      if !TMP
         return
   }
   Loop, parse, A_GuiEvent, `n
   {
      name:=basename(A_LoopField)
      ToolTip, % "Sending " . name . "..."
      command:="push """ . A_LoopField  . """ """ . ((TMP) ? TMP : from) . """"
      write_file("`nADB -> (" . command . ") -> (" . adb_serial(command) . ")`n", general_log)
      if TMP {
         command:="mv -f """ . TMP . "/" . name """ """ . from . """"
         write_file("`n(" . command . ") -> (" . adb_shell(command) . ")`n", general_log)
      }
   }
   SetTimer, RemoveToolTip, -100
   goto explorer_load
   return
   explorer_load:
      GuiControl, exp:, current_path, % from
      ToolTip, % "Loading " . from . " contents..."
      tree:=[], dir:=SubStr(from,0)="/" ? from : from . "/", selected:={}
      Loop, parse, % adb_shell("ls -lb """ . dir . """ 2>dev/null"), `n,`r 
      {
         if (chr:=SubStr(A_LoopField,1,1)) {
            if (chr~="^-|l|d|b|c$") && RegExMatch(A_LoopField, (chr="l") ? "(?:(?:(?:\\\s|\S)+)(?=\s+\-\>\s+))|(?:(?:\\\s|\S)+\s*$)" : "(?:\\\s|\S)+\s*$", name) {
               switch (chr) {
                  case "d":
                     icon:=current . "\images\folder.png"
                  case "l":
                     icon:=current . "\images\link.png"
                  default:
                     icon:=current . "\images\file.png", (chr="-") ? chr:="f"
               }
               name:=StrReplace(name, "\"), tree.Push({path:dir . name, dir:from, name:name, type:chr, icon:icon})
            }
         }
      }
      if !(total:=tree.MaxIndex()) {
         MsgBox, % 262144 + 4 + 32, HELP, Empty folder: %from%`n`nDo you want to return?
         IfMsgBox, Yes
         {
            if (from="/") {
               from="/sdcard"
               goto explorer_load
            } else {
               goto explorer_back
            }
         }
      }
      LV_SetImageList(IconList:=IL_Create(total)), LV_SetImageList(IconList2:=IL_Create(total,,true))
      SetTimer, RemoveToolTip, -100
      goto explorer_find
   return
   explorer_list:
      on_action:=ErrorLevel
      GuiControl, exp:-g, explorer_list
      If (A_GuiEvent = "DoubleClick") {
         LV_GetText(type, A_EventInfo, 3)
         switch (type) {
            case "d","l":
               GuiControl, exp: -g, to_find_exp
               LV_GetText(name, A_EventInfo, 1)
               from:=dir . name
               GuiControl, exp:, to_find_exp,
               gosub explorer_load
               GuiControl, exp:+gexplorer_find, to_find_exp
            case "f":
               open:=current . "\tmp"
               gosub explorer_export
               open:=""
         }
      } else if (A_GuiEvent = "RightClick") {
         Menu, MenuExp, Show
      } else if (A_GuiEvent = "I") {
         StringCaseSense, On
         Loop, Parse, on_action
         {
            ;Case "F":;Focused Case "f":;Defocused Case "C":;Checked" Case "c":;Unchecked
            switch (A_LoopField)
            {
               case "S": ;Selected
                  selected[A_EventInfo]:=true
               Case "s": ;Deselected
                  (selected[A_EventInfo]) ? selected.RemoveAt(A_EventInfo)
            }
         }
         StringCaseSense, Off
      }
      GuiControl, exp:+gexplorer_list, explorer_list
   return
   explorer_find:
      GuiControl, exp:-g -Redraw, explorer_list
      Gui exp: Default 
      LV_Delete()
      Sleep 250
      GuiControl, exp: -g, to_find_exp
      Gui exp: Submit, NoHide
      at_pos:=0, selected:={}
      for key, file in tree
      {
         if (!skip)&&(InStr(file.name, to_find_exp)) {
            at_pos++
            IL_Add(IconList, file.icon, 0xFFFFFF, true), LV_Add("Icon" . IL_Add(IconList2, file.icon, 0xFFFFFF, true), file.name, file.dir, file.type)
         }
      }
      LV_ModifyCol(3, "Sort")
      Loop % LV_GetCount("Column")
         LV_ModifyCol(A_Index, "AutoHdr")
      GuiControl, exp:+gexplorer_list +Redraw, explorer_list
      GuiControl, exp:+gexplorer_find, to_find_exp
   return
}
console(title:="AutoIMG-Console",tool:="",w:=600,h:=300) {
   global mx, my, style, cmdpid, console_command, console_tool, consolehwnd, console_commandhwnd, congui, conFind, confindgui, console_predict
   if tool.MaxIndex() {
      for cont, file in tool
      {
         if InStr(FileExist(file), "A") {
            (list) ? list.="|"
            list.=basename(file)
         } else {
            MsgBox, % 262144 + 16, HUH, Cant find file:`n`n%file%
            return 0
         }
      }
      tool.Push(comspec), list.="|cmd.exe"
   } else {
      tool:={1: comspec}, list:="cmd.exe"
   }
   DetectHiddenWindows, On
   Gui confind: +Hwndconfindgui +AlwaysOnTop -Caption
   Gui confind: Font, s10 w700 cC0C0C0, Courier New
   Gui confind: Color,, 000000
   Gui confind: Add, ListBox, vconFind gconfindselect x0 y0 w200 Center Sort,
   Gui con: Default 
   Gui con: +Hwndcongui +AlwaysOnTop +Resize
   Gui con: margin, 0, 0
   Gui con: Font, s10, %style%
   Gui con: Add, DropDownList, AltSubmit center x5 y5 w100 vconsole_tool Section, % list
   Gui con: Font, s10 w700 cC0C0C0, Courier New
   Gui con: Color,, 000000
   Gui con: Add, Edit, % "X+5 YP vconsole_command Hwndconsole_commandhwnd gconsole_find w" . w - 130,
   Gui con: Add, Button, Hidden Default w0 h0 gconsole_event, RUN
   Gui con: Add, Button, XS Y+5 w100 gconsole_path, SET PATH
   Gui con: Add, Button, X+5 YP w100 gconsole_select, SELECT FILE
   Gui con: Add, CheckBox, X+5 YP w100 vconsole_predict gconsole_find cblack, Predictive
   Gui con: Add, Edit, Hwndconsolehwnd x0 Y+5 w%w% h%h% 0x200 border HScroll,
   Gui con: Show, Autosize Center, % title
   GuiControl, con:Choose, console_tool, 1
   GuiControl, con:, console_predict, 1
   ;WinSet, Transparent, 230, ahk_id %congui%
   Gui con: +LastFound
   Sleep 50
   ControlFocus, console_command, ahk_class AutoHotkeyGUI 
   WinWaitClose
   return
   console_event:
      Gui con: Submit, NoHide
      GuiControlGet, command, con:, console_command
      if command:=Trim(command) {
         if (tool[console_tool]=ComSpec) {
            stdout.="> " . command . "`r`n`r`n", command:=StrReplace(command, "\""", "\\\""")
         } else {
            stdout.="> " . basename(tool[console_tool]) . A_Space . command . "`r`n`r`n", command:="""" . tool[console_tool] . """ " . StrReplace(command, "\""", "\\\""")
         }
         shell:=comobjcreate("wscript.shell"), exec:=(shell.exec(comspec . " /c """ . command . " 2>&1""")), cmdpid:=exec.ProcessID
         while,!exec.StdOut.AtEndOfStream
         {
            GuiControl, con:, %consolehwnd%, % stdout.="   " . exec.StdOut.readline() . "`r`n"
         }
         GuiControl, con:, %consolehwnd%, % stdout.="`r`n"
         SendMessage, EM_SETSEL:=0x00B1, -2, -1, , ahk_id %consolehwnd%
         PostMessage, EM_SCROLLCARET:=0xB7, 0, 0,, ahk_id %consolehwnd%
         exec.StdOut.Close(),exec.StdErr.Close(),exec.StdIn.Close(),exec.Terminate()
         Process, Close, % cmdpid
         cmdpid:=""
      }
   return
   conGuiClose:
      if cmdpid {
         exec.StdOut.Close(),exec.StdErr.Close(),exec.StdIn.Close(),exec.Terminate()
         Process, Close, % cmdpid
         cmdpid:=""
      }
      if console_tool
         Process, Close, % basename(tool[console_tool])
      Gui con: Destroy
      Gui confind: Destroy
      SetWorkingDir, % A_ScriptDir
      AutoXYWH("reset")
   return
   conGuiSize:
      if (A_EventInfo = 1)
         return
      AutoXYWH("w", "console_command"), AutoXYWH("wh", consolehwnd)
   return
   console_find:
      Sleep 250
      Gui con: Submit, NoHide
      if (console_predict=0) {
         Gui confind: Hide
         SetTimer, confindfollow, Off
         return
      }
      GuiControlGet, command, con:, console_command
      words:=""
      if RegExMatch(command, "^(?:(?:\s*(?:""[^""]+""|\S+)\s+)*)\s*\K(?:(?:""\K[^""]+)|\S+)$", command) {
         len:=StrLen(command)
         Loop, Files, % A_WorkingDir . "\*", FD
         {
            if (SubStr(A_LoopFileName,1,len)=command) {
               (words) ? words.="|"
               words.=A_LoopFileName
            }
         }
      }
      if words {
         GuiControl, confind:, conFind, |%words%
         SetTimer, confindfollow, 10
         Gui confind: Show, Autosize Center
      } else {
         Gui confind: Hide
         SetTimer, confindfollow, Off
      }
      GuiControl, con:Focus, console_command
   return
   console_path:
      Gui con: -AlwaysOnTop
      FileSelectFolder, from, , , Select the new work path:
      if from {
         SetWorkingDir, % from
         GuiControl, con:Focus, console_command
         GuiControl, con:, %consolehwnd%, % stdout.="> cd """ . from . """`r`n`r`n"
         SendMessage, EM_SETSEL:=0x00B1, -2, -1, , ahk_id %consolehwnd%
         PostMessage, EM_SCROLLCARET:=0xB7, 0, 0,, ahk_id %consolehwnd%
      }
      Gui con: +AlwaysOnTop
   return
   console_select:
      Gui con: -AlwaysOnTop
      Gui con: Submit, NoHide
      FileSelectFile, file, 1, , Select a file as parameter, All Files (*.*)
      if file {
         GuiControl, con:, console_command, % console_command . " """ . file . """"
         GuiControl, con:Focus, console_command
         SendMessage, 0xB1, -2, -1,, ahk_id %console_commandhwnd%
         SendMessage, 0xB7,,,, ahk_id %console_commandhwnd%
         WinGetPos, toolX, toolY, toolW, toolH, ahk_id %congui%
         WinMove, ahk_id %congui%,,,, toolW-1, toolH-1
         WinMove, ahk_id %congui%,,,, toolW, toolH
      }
      Gui con: +AlwaysOnTop
   return
   confindselect:
      if (A_GuiControlEvent="DoubleClick") {
         Gui confind: Submit, NoHide
         GuiControl, con:, console_command, % RegExReplace(console_command, "^(?:(?:\s*(?:""[^""]+""|\S+)\s+)*)\s*\K(?:(?:""[^""]+)|\S+)$", """" . confind . """")
         SendMessage, 0xB1, -2, -1,, ahk_id %console_commandhwnd%
         SendMessage, 0xB7,,,, ahk_id %console_commandhwnd%
         Gui confind: Hide
         SetTimer, confindfollow, Off
         WinGetPos, toolX, toolY, toolW, toolH, ahk_id %congui%
         WinMove, ahk_id %congui%,,,, toolW-1, toolH-1
         WinMove, ahk_id %congui%,,,, toolW, toolH
      }
   return
   confindfollow:
      WinGetPos, toolX, toolY, toolW, toolH, ahk_id %congui%
      WinGetPos, newX, newY, newW, newH, ahk_id %confindgui%
      if (toolY<newH) {
         Gui con: -AlwaysOnTop
         WinMove, ahk_id %confindgui%,, toolX + ((toolW - newW ) // 2), toolY + (newH+50)
      } else {
         WinMove, ahk_id %confindgui%,, toolX + ((toolW - newW ) // 2), toolY - newH
      }
   return
}
app_manager(list:="") {
   global mx, my, style, appcontrol, HeaderColors, serial, currentdevice, app_manager, general_log, current, appcontrol_icons, to_find, appcontrol_findhwnd, default_mode_app, default_mode_app_type, total_apps, to_install, to_uninstall
   StringCaseSense, Off
   if serial && !check_active(serial)
      return 0
   Print(">> Manager: " . currentdevice.name)
   if !push(app_manager,"/data/local/tmp")
      return 0
   if list&&InStr(FileExist(list), "A") {
      Print(">> Manager: Loading list...")
      if (SubStr(ObjHeader(list),0)="A") {
         state:=ObjLoad(list)
      } else {
         MsgBox, % 262144 + 16, App Manager, Invalid file format`n`n-> %list%
         return 0
      }
   } else {
      list:="",state:={}
   }
   Print(">> Manager: Loading apps...")
   app:={}
   Loop, parse, % adb_shell("export CLASSPATH=/data/local/tmp/app_manager; (app_process / Main) 2>/dev/null"), `n,`r
      (!user&&SubStr(A_LoopField,1,5)="USER:") ? (user:=SubStr(A_LoopField,6)) : ((info:=StrSplit(StrReplace(A_LoopField, Chr(0xA0), A_Space), ":")) ? (info.MaxIndex()=6) ? app[info.4]:={state:(info.1="ENABLED")?1:((info.1="DISABLED")?0:-1), is_system:(info.2="SYSTEM")?1:0, uid:info.3, path:info.5, name:info.6})
   if !(total_apps:=app.Count()) {
      MsgBox, % 262144 + 64, HUH, Could not get information from any app
      return 0
   }
   Print(">> Manager: Loading opts...")
   smanager:=adb_shell("pm help")
   install_existing:=InStr(smanager,"install-existing")?true:false
   if (user="null") {
      Print(">> Manager: Success")
      user:=""
   } else {
      Print(">> Manager: Success in User-" . user)
      user:=InStr(smanager,"--user")?"--user " . user . " ":""
   }
   smanager:=""
   IniRead, app_msg, % current "\configs.ini", GENERAL, app_msg, 0
   (app_msg=0) ? help(current "\images\app_guide.png", "Please note that UNMARKED apps will be uninstalled.")
   IniWrite, 1, % current "\configs.ini", GENERAL, app_msg
   Gui app: New 
   Gui app: Default 
   Gui app: +AlwaysOnTop
   Gui app: margin, %mx%, %my%
   Gui app: Font, s10, %style%
   Gui app: Add, Edit, w320 hwndappcontrol_findhwnd vto_find gappcontrol_find Section,
   Gui app: Add, DropDownList, AltSubmit center X+0 YP w100 vdefault_mode_app gappcontrol_find, All apps|Enabled|Disabled|Uninstalled
   Gui app: Add, DropDownList, AltSubmit center X+0 YP w100 vdefault_mode_app_type gappcontrol_find, System-User|System|User
   Gui app: Add, ListView, AltSubmit -ReadOnly hwndappmanager NoSortHdr -LV0x10 LV0x20 Checked gappcontrol vappcontrol XS Y+0 w520 h200, |Name|Package|Path
   Gui app: Font, s9, %style%
   Gui app: Add, Text, XS Y+0, Total apps:
   Gui app: Add, Text, X+5 YP vtotal_apps, %total_apps%
   Gui app: Add, Text, X+130 YP, UNINSTALL:
   Gui app: Add, Text, X+5 YP vto_uninstall, 0
   Gui app: Add, Text, X+150 YP, INSTALL:
   Gui app: Add, Text, X+5 YP vto_install, 0
   Gui app: Font, s10, %style%
   Gui app: Add, Text, XS+30 Y+20 Section, The changes will not be applied unless you click
   Gui app: Add, Text, XP Y+15, You can export your current selection
   Gui app: Add, Text, XP Y+20, You can switch between Icon Mode
   Gui app: Font, s10, Arial Black
   Gui app: Add, Text, X+90 YS c254EC5, -►
   Gui app: Add, Text, XP Y+15 c254EC5, -►
   Gui app: Add, Text, XP Y+20 c254EC5, -►
   Gui app: Font, s10, %style%
   Gui app: Add, Button, center X+30 YS-5 h30 w100 gappcontrol_do, APPLY
   Gui app: Add, Button, center XP Y+5 h30 w100 gappcontrol_export, EXPORT
   Gui app: Add, Button, center XP Y+5 h30 w100 gappcontrol_icons vappcontrol_icons, LOAD ICONS
   GuiControl, app:Choose, default_mode_app, 1
   GuiControl, app:Choose, default_mode_app_type, 1
   if list {
      to_uninstall:=0, to_install:=0
      for pkg, with_state in state
      {
         if app.HasKey(pkg) {
            if !(app[pkg].state=with_state||(!with_state&&app[pkg].state=-1)) {
               (app[pkg].state>0)?to_uninstall+=1:to_install+=1
            }
         }
      }
      GuiControl, app:, to_uninstall, % to_uninstall
      GuiControl, app:, to_install, % to_install
   }
   gosub appcontrol_find
   HHDR := DllCall("SendMessage", "Ptr", appmanager, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr") ; LVM_GETHEADER
   HeaderColors[HHDR] := {Txt: 0xFFFFFF, Bkg: 0x797e7f} ; BGR
   SubClassControl(appmanager, "HeaderCustomDraw")
   SetEditCueBanner(appcontrol_findhwnd, "Search by name or package...")
   Gui app: show, AutoSize Center, App Manager
   WinSet, Redraw, , ahk_id %HHDR%
   Gui app: +LastFound
   WinWaitClose
   return
   appGuiClose:
   SubClassControl(appmanager, "")
   Gui app: Destroy
   return
   appcontrol:
   on_action:=ErrorLevel, on_col:=LV_SubItemHitTest(appmanager)
   GuiControl, app:-g, appcontrol
   if (on_col=1) {
      If (A_GuiEvent == "I") {
         If ((on_action == "C") || (on_action == "c")) && LV_GetText(pkg, A_EventInfo, 3) {
            state[pkg]:=(on_action == "C") ? 1 : 0
            guikey:=(app[pkg].state>0)?"to_uninstall":"to_install"
            GuiControlGet, count, app:, % guikey
            GuiControl, app:, % guikey, % count + ((app[pkg].state=state[pkg]||(!state[pkg]&&app[pkg].state=-1)) ? -1 : 1)
         }
      }
   }
   if (loaded_icons&&on_col=1)||(on_col>1) {
      If (A_GuiEvent = "DoubleClick" && LV_GetText(copy, A_EventInfo,on_col)) {
         ToolTip, % "Copied " . copy
         Clipboard := "", Clipboard := copy
         SetTimer, RemoveToolTip, -1000
      }
   }
   GuiControl, app:+gappcontrol, appcontrol
   return
   appcontrol_icons:
   if icons_mode {
      GuiControl, app:, appcontrol_icons, LOAD ICONS
   } else {
      GuiControl, app:, appcontrol_icons, GO BACK
   }
   icons_mode:=!icons_mode
   if icons_mode&&!loaded_icons {
      Gui app: Default
      LV_Delete()
      LV_Add("", "", "Loading icons...")
      LV_Add("", "", "This process can take a long time."), LV_ModifyCol(2, "AutoHdr")
      dest:=current . "\tmp"
      FileCreateDir, % dest
      FileRemoveDir, % dest . "\app_manager_icons", 1
      write_file(adb_shell("export CLASSPATH=/data/local/tmp/app_manager; (app_process / Main -icon /data/local/tmp/app_manager_icons) 2>/dev/null"),general_log)
      write_file(adb("pull /data/local/tmp/app_manager_icons """ . dest . """"),general_log)
      dest.="\app_manager_icons\", default_icon:=current . "\images\app.png"
      for pkg, props in app
      {
          app[pkg].icon:=(InStr(FileExist(out:=dest . pkg . ".png"), "A")) ? out : default_icon
      }
      LV_SetImageList(IconList:=IL_Create(total_apps)), LV_SetImageList(IconList2:=IL_Create(total_apps,,true))
   }
   loaded_icons:=true
   goto appcontrol_find
   return
   appcontrol_do:
   gosub appGuiClose
   smanager:={}
   for pkg, with_state in state
   {
      if app.HasKey(pkg) {
         if with_state {
            switch (app[pkg].state)
            {
               case 0:
                  smanager.Push("pm enable " . user . pkg)
               case -1:
                  smanager.Push(((install_existing) ? "pm install-existing " . user . pkg : "pm install -r " . user . """" app[pkg].path """"))
            }
         } else if (app[pkg].state>0) {
            smanager.Push("pm uninstall " . user . pkg)
         }
      }
   }
   at_pos:=0,error:=0
   Print(">> Manager: Running...")
   Loop, parse, % adb_shell(StrJoin(smanager,";")), `n,`r
   {
      if (A_LoopField) {
         at_pos++
         if (A_LoopField~="i)Failure|error") {
            if !error
               MsgBox, % 262144 + 16, HUH, % smanager[at_pos] . "`n`nThis command ended in ERROR! Check the log"
            error++
         }
         write_file("`n(" . smanager[at_pos] . ") -> " A_LoopField . "`n",general_log)
      }
   }
   Print(">> Manager: " . (at_pos-error) " changes were made" . ((error)?", " . error . " errors":""))
   smanager:=""
   return
   appcontrol_export:
   Gui app: -AlwaysOnTop
   start_date:=A_Now
   FormatTime, start_date,, dd_M_yyyy-hh_mm_ss
   FileSelectFile, export, S, % "AppList_(" . start_date .  ").aid", Define where to save the file, AutoIMGData (*.aid)
   if export&&!ObjDump(export,state,,"A") {
      MsgBox, % 262144 + 16, HUH, Could NOT export data!
   }
   Gui app: +AlwaysOnTop
   return
   appcontrol_find:
   GuiControl, app:-g -Redraw, appcontrol
   Gui app: Default 
   LV_Delete()
   Sleep 250
   GuiControl, app: -g, to_find
   Gui app: Submit, NoHide
   at_pos:=0
   if icons_mode {
      GuiControl, app:+Icon, appcontrol
   } else {
      GuiControl, app:+Report, appcontrol
   }
   for pkg, props in app
   {
      switch (default_mode_app_type)
      {
         case 1:
            skip:=false
         case 2:
            (props.is_system) ? skip:=false : skip:=true
         case 3:
            (!props.is_system) ? skip:=false : skip:=true 
      }
      if !skip {
         with_state:=(state[pkg]!="") ? state[pkg] : props.state
         switch (default_mode_app)
         {
            case 1:
               skip:=false
            case 2:
               (with_state=1) ? skip:=false : skip:=true
            case 3:
               (with_state=0) ? skip:=false : skip:=true
            case 4:
               (props.state=-1) ? skip:=false : skip:=true
         }
         if (!skip)&&(InStr(props.name, to_find)||InStr(pkg, to_find)) {
            at_pos++
            if loaded_icons
               IL_Add(IconList, props.icon, 0xFFFFFF, true), LV_Add("Icon" . IL_Add(IconList2, props.icon, 0xFFFFFF, true), props.name, "", pkg, props.path)
            else
               LV_Add("", "", props.name, pkg, props.path)
            (with_state>0) ? LV_Modify(at_pos, "Check")
         }
      }
   }
   if !icons_mode {
      Loop % LV_GetCount("Column")
         LV_ModifyCol(A_Index, "AutoHdr")
   }
   GuiControl, app:+gappcontrol +Redraw, appcontrol
   GuiControl, app:+gappcontrol_find, to_find
   Return
}
install_manager(data:="") {
   global mx, my, style, installcontrol, install_files, all_formats, current, HeaderColors, formats, unexpected
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
   (!ext) ? ext := "*.img;*.zip;*.apk;*.cpio"
   if data&&InStr(FileExist(data), "A") {
      Print(">> Manager: Loading list...")
      if (SubStr(ObjHeader(data),0)="I") {
         install_files:=ObjLoad(data)
         Print(">> Manager: Success")
      } else {
         MsgBox, % 262144 + 16, Installation Manager, Invalid file format`n`n-> %data%
         return 0
      }
   } else {
      data:=""
   }
   Gui 3: Destroy
   Gui 3: Default 
   Gui 3: +AlwaysOnTop
   Gui 3: margin, %mx%, %my%
   Gui 3: Font, s10, %style%
   Gui 3: Add, ListView, AltSubmit -ReadOnly hwndmanager NoSortHdr -LV0x10 LV0x20 Checked vinstallcontrol Y+0 w320 h200, |Partition|File to install
   Gui 3: Add, Button, Center Y+0 w320 ginstallcontrol_export, EXPORT
   LV_Delete()
   list := New LV_InCellEdit(manager)
   list.SetColumns(2)
   for index, file in install_files {
      if data && !InStr(FileExist(file.file), "A") {
         MsgBox, % 262144 + 48 + 1, Request, % file.file "`n`nThis file is intended for the partition """ file.part """ but it DOES NOT EXIST!"
         ifMsgBox OK
         {
            FileSelectFile, getfile, 1,, Please select some IMG to Install, (%ext%)
            (getfile) ? (install_files[index].file:=file.file:=getfile)
         } else {
            getfile:=""
         }
         if !getfile {
            print(">> Loaded list removed!")
            install_files:={}
            return 0
         }
      }
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
   GuiControl, 3:+ginstallcontrol, installcontrol
   WinWaitClose, Installation Manager
   Gui 3: Destroy
   installcontrol:
   If (list["Changed"]) {
       Gui 3: Default 
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
		    MsgBox, % 262144 + 64, HELP, You cant put an empty partition
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
         Gui 3: Default 
	      Gui 3: -AlwaysOnTop
         FileSelectFile, file, 1,, Please select some IMG to Install, (%ext%)
         if file {
            install_files[A_EventInfo].file := file
            LV_Modify(A_EventInfo, "Col3", file)
            LV_ModifyCol(3, "AutoHdr")
            ext_file:=extname(file)
            if !(install_files[A_EventInfo].part="UPDATE FILE") && (ext_file="zip" || ext_file="apk") {
               install_files[A_EventInfo].is_zip:=true
               install_files[A_EventInfo].part:="ZIP FILE"
               LV_Modify(A_EventInfo, "Col2", "ZIP FILE")
               LV_ModifyCol(2, "AutoHdr")
               if (install_files.MaxIndex()=A_EventInfo)
                  GuiControl, 1:, partition, ZIP FILE
               if (zip_msg!=1) {
                  help(current "\images\recoverys.png", "The installation of ZIPs requires a Custom Recovery (Or device Booted + Root), so`nAll loaded ZIPs will be installed after the IMGs and not in load order")
                  IniWrite, 1, % current "\configs.ini", GENERAL, zip_msg
               }
            } else if (ext_file="cpio") {
               install_files[A_EventInfo].is_ramdisk:=true
               install_files[A_EventInfo].part:="RAMDISK FILE"
               LV_Modify(A_EventInfo, "Col2", "RAMDISK FILE")
               LV_ModifyCol(2, "AutoHdr")
               if (install_files.MaxIndex()=A_EventInfo)
                  GuiControl, 1:, partition, RAMDISK FILE
            }
	     }
		  Gui 3: +AlwaysOnTop
	  }
   }
   return
   installcontrol_export:
   gosub installcontrol
   Gui 3: -AlwaysOnTop
   start_date:=A_Now
   FormatTime, start_date,, dd_M_yyyy-hh_mm_ss
   FileSelectFile, export, S, % "Installation_(" . start_date .  ").aid", Define where to save the file, AutoIMGData (*.aid)
   if export&&!ObjDump(export,install_files,,"I") {
      MsgBox, 262144, HUH, Could NOT export data!
   }
   Gui 3: +AlwaysOnTop
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
      MsgBox, % 262144 + 16, ERROR, % result
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
	   MsgBox, % 262144 + 16, ERROR, Cant reboot in fastboot
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
			   result := run_cmd("""" A_LoopFileDir "/64bits.exe" """")
			   break
			} else if !A_Is64bitOS && FileExist(A_LoopFileDir "/32bits.exe") {
			   result := run_cmd("""" A_LoopFileDir "/32bits.exe" """")
			   break
			}
			result .= run_cmd("pnputil -i -a " """" A_LoopFileLongPath """")
	     } else {
		    nospam := true
			IniWrite, 1, % current "\configs.ini", GENERAL, drivers
	        break
	     }
	  } else {
	     result .= run_cmd("pnputil -i -a " """" A_LoopFileLongPath """")
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
			      result := run_cmd("""" A_LoopFileDir "/64bits.exe" """")
			      break
			   } else if !A_Is64bitOS && FileExist(A_LoopFileDir "/32bits.exe") {
			      result := run_cmd("""" A_LoopFileDir "/32bits.exe" """")
			      break
			   }
			   result .= run_cmd("pnputil -i -a " """" A_LoopFileLongPath """")
	        } else {
			   nospam := true
			   IniWrite, 1, % current "\configs.ini", GENERAL, drivers
	           break
			}
	     } else {
	        result .= run_cmd("pnputil -i -a " """" A_LoopFileLongPath """")
	     }
      }
   }
   if pass {
     if result
        write_file(result, general_log)
     if (exitcode<=0)||(result ~= "i)\berror|failed\b") {
	    write_file("`nDriver installation ended with:" exitcode " `n", general_log)
	    print(">> Cant install drivers!")
		MsgBox, % 262144 + 16, ERROR, The drivers were not installed correctly
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
      MsgBox, % 262144 + 16, ERROR, % "A problem formatting the device storage!"
	  return 0
   }
   return 1
}
push(file, dest) {
   global exist_device, device_mode, general_log, ensure_recovery, serial
   if (serial && !check_active(serial))
      return 0
   if !exist_device
      return 0
   if !FileExist(file) {
      MsgBox, % 262144 + 16, ERROR, % "Cant find " file
      return 0
   }
   if (device_mode="fastboot") {
      gosub reboot_recovery
	   adb_shell("setprop sys.usb.config mtp,adb; setprop sys.usb.ffs.mtp.ready 1")
      ensure_shell()
   }
   result := adb_shell("[ ! -d " """" dest """" " ] && mkdir -p " """" dest """")
   print(">> Sending " basename(file) "...")
   ensure_shell()
   if (device_mode="recovery") {
      Sleep, 1000
      ensure_shell()
   }
   result .= adb_serial("push " """" file """" " " """" dest """")
   result .= adb_shell("[ ! -f " """" dest "/" basename(file) """" " ] && echo " """" "ERROR: Cant find " basename(file) """")
   if (result ~= "i)\berror|failed\b") {
      write_file(result, general_log)
      MsgBox, % 262144 + 16, ERROR, % "Unable to load " basename(file) " on the device"
	  return 0
   }
   return 1
}
pull(file, dest) {
   global exist_device, device_mode, general_log, ensure_recovery, serial
   if (serial && !check_active(serial))
      return 0
   if !exist_device
      return 0
   if (device_mode="fastboot") {
      gosub reboot_recovery
	   adb_shell("setprop sys.usb.config mtp,adb; setprop sys.usb.ffs.mtp.ready 1")
      ensure_shell()
   }
   if !exist_file(file) {
      MsgBox, % 262144 + 16, ERROR, % "Cant find " file " on the device"
      return 0
   }
   FileCreateDir(dest)
   print(">> Getting " basename(file) "...")
   ensure_shell()
   if (device_mode="recovery") {
      Sleep, 1000
      ensure_shell()
   }
   result .= adb_serial("pull " """" file """" " " """" dest """")
   if (result ~= "i)\berror|failed\b") || !FileExist(dest "\" basename(file)) {
      write_file(result, general_log)
      MsgBox, % 262144 + 16, ERROR, % "Unable to get " basename(file)
	  return 0
   }
   return 1
}
setup_busybox(to_dir, dest := "") {
   global busybox, general_log, busybox_work, device_mode, TMP
   busybox_work:=""
   if (device_mode="booted") {
      back_tmp:=TMP
      TMP:=ensure_tmp()
      if !push(busybox, TMP)
         return 0
      result := adb_shell("mkdir -p """ to_dir """ 2>/dev/null; mv -f " TMP "/" basename(busybox) " """ to_dir """")
      TMP:=back_tmp
   } else if !push(busybox, to_dir) {
      return 0
   }
   busybox_work := to_dir "/" basename(busybox)
   print(">> Busybox: Loading...")
   sbusybox=
   (
      if [ -f "%busybox_work%" ]; then
         chmod 777 "%busybox_work%"
         if [ -n "%dest%" ]; then
            rm -rf "%dest%"
            mkdir -p "%dest%"
            "%busybox_work%" --install -s "%dest%"
            [ ! -e "%dest%/unzip" ] && echo "ERROR: Cant setup busybox"
         else
            "%busybox_work%" unzip --help || echo "ERROR: Cant setup busybox"
         fi
      else
         echo "ERROR: Cant find busybox"
      fi
   )
   result.=sh(sbusybox)
   if (result ~= "i)\berror|failed\b") {
      busybox_work:=""
      write_file(result, general_log)
	   MsgBox, % 262144 + 16, ERROR, % "Cant setup " basename(busybox)
	   return 0
   }
   print(">> Busybox: Success")
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
	   MsgBox, % 262144 + 16, ERROR, % "Cant find " any " on the device"
       return 0
   }
   result .= adb_shell("cp -rf " """" any """" " " """" to """" " && echo Success")
   if InStr(result, "Success") {
      return 1
   } else {
      MsgBox, % 262144 + 16, ERROR, % "Cant copy " any " in " to
      write_file(result, general_log)
      return 0
   }
}
run_binary(binary, action := ""){
   global exist_device, device_mode, serial, general_log, cache
	if (serial && !check_active(serial))
      return 0
	if (device_mode="fastboot") {
	   MsgBox, % 262144 + 16, ERROR, The run_binary function is not supported from fastboot
	   return 0
	}
   if !IsObject(cache)
      optimize()
	if (cache.commands.HasKey(binary)&&at:=cache.commands[binary])||(at:=Trim(adb_shell("bin=$(command -v " binary "); [ -e ""$bin"" ] && echo $bin"),"`n`r" A_Space "`t")) {
      write_file("`n" Format("{:U}",at) " command support`n", general_log)
	} else {
      if action
	      MsgBox, % 262144 + 16, ERROR, % binary " command is not supported by device"
      return 0
	}
   return (action) ? adb_shell("""" at """ " action) : at
}
ensure_tmp(needexec := ""){
   global general_log, device_mode, TMP
   if needexec {
      if (TMP&&(TMP ~= "^/sdcard")) {
         result.="`nTMP: Unable to execute scripts in " TMP "`n"
      }
      using:="/tmp /dev/tmp__ /cache/tmp__ /mnt/tmp__ /data/tmp__ /data/local/tmp__"
   } else if (device_mode="booted") {
      if (TMP&&!(TMP ~= "^/sdcard")) {
         result .= "`nTMP: Unable to pass files to " TMP " because the device is booted"
      }
      using:="/sdcard/tmp"
   } else {
      using:="/tmp /dev/tmp__ /cache/tmp__ /mnt/tmp__ /data/tmp__ /data/local/tmp__"
   }
   stmp=
   (
      for TMP in %using%; do
            [ "$TMP" != "/tmp" ] && mkdir -p $TMP
            if [ -d "$TMP" ]; then
               echo "echo Im fine" > $TMP/tmp.sh
               chmod 777 $TMP/tmp.sh
               if [ -n "%needexec%" ]; then
                  if [ "$($TMP/tmp.sh)" = "Im fine" ]; then
                     rm -f $TMP/tmp.sh
                     echo "TMP == $TMP"
                     break
                  else
                     rm -rf $TMP
                     echo "TMP: $TMP UNSUPPORTED"
                  fi
               elif [ -f "$TMP/tmp.sh" ]; then
                  rm -f $TMP/tmp.sh
                  echo "TMP == $TMP"
                  break
               else
                  echo "TMP: $TMP is Read/Only"
               fi
            fi
      done
   )
   result.=TMP:=sh(stmp)
   if (_at:=InStr(TMP, "==")) {
      TMP:=Trim(SubStr(TMP, _at+2), "`n`r" A_Space "`t")
   } else {
      TMP:=""
		MsgBox, % 262144 + 16, ERROR, Cannot create a temp directory on the device
   }
   write_file(result, general_log)
   return TMP
}
flash_zip(zip) {
   global exist_device, device_mode, general_log, ensure_recovery, serial, busybox_work
   if (serial && !check_active(serial))
      return 0
   if !exist_device
      return 0
   if (ensure_recovery=1 && device_mode!="recovery")||(device_mode="fastboot") {
      gosub reboot_recovery
	   adb_shell("setprop sys.usb.config mtp,adb; setprop sys.usb.ffs.mtp.ready 1")
      ensure_shell()
   }
   if !(TMP:=ensure_tmp(true))
      return 0
   if !exist_file(zip) {
      MsgBox, % 262144 + 16, ERROR, % "Cant find """ zip """ on the device"
      return 0
   }
   run_binary("twrp") && twrp := true
   run_binary("unzip") && unzip := true
   print(">> Installing " """" ubasename(zip) """")
   print(">> Please wait...")
   if twrp && unzip {
      result .= adb_shell("twrp install " """" zip """")
   } else {
      if !unzip && !(busybox_work||setup_busybox(TMP))
	     return 0
      print(">> Loading environment...")
      szip=
      (
         rm -rf "%TMP%/META-INF"
         if [ -n "%unzip%" ]; then
            unzip -qo "%zip%" META-INF/com/google/android/update-binary -d "%TMP%" 
         else
            "%busybox_work%" unzip -qo "%zip%" META-INF/com/google/android/update-binary -d "%TMP%" 
         fi
         if [ -f "%TMP%/META-INF/com/google/android/update-binary" ]; then
            sh "%TMP%/META-INF/com/google/android/update-binary" 3 3 "%zip%"
         else
            echo ERROR: Cant extract update-binary
         fi
      )
	   result .= "-------------" ubasename(zip) "-------------`n" 
	   result .= sh(szip)
	   result .= "------------------------------------------`n"
      if (result ~= "i)\berror:\b") {
	     write_file(result, general_log)
	     MsgBox, % 262144 + 16, ERROR, % "Cant execute " ubasename(zip)
	     return 0
	   }
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
	   adb_shell("setprop sys.usb.config mtp,adb; setprop sys.usb.ffs.mtp.ready 1")
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
   if (type = "MD5") {
		HashAlg:=1
   } else if (type = "MD2") {
		HashAlg:=2
   } else if (type = "SHA1") {
		HashAlg:=3
   } else if (type = "SHA256") {
		HashAlg:=4
   } else if (type = "SHA384") {
		HashAlg:=5
   } else if (type = "SHA512") {
		HashAlg:=6
   } else {
	  write_file("`nUnsupported hash type: " type "`n", general_log)
	  return
   }
   if !(hash := Crypt.Hash.FileHash(file,HashAlg,pwd:="",hmac_alg:=1)) {
      write_file("`nCant get hash of: " file "`n", general_log)
   } else {
      return hash
   }
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

      [tools\apktool.jar]
      SHA256 7b4a8e1703e228d206db29644b71141687d8a111b55b039b08b02dfa443ab0f9 #apktool 2.8.1
      
      [tools\sign.jar]
      SHA256 0f002a2613ad7dbc2a348fd93b01dab90321727fa6e74a9ef48a30104a5dcf67

      [tools\zipalign.exe]
      SHA256 e1669c0dbd337810224292d3a8e8cb87fb8074bde609b6bbb3dede83c99082ed

      [tools\7za.exe]
      SHA256 f00836a63be7ebf14e1b8c40100c59777fe3432506b330927ea1f1b7fd47ee44 #2023-06-20

      [tools\7za.dll]
      SHA256 a3fc74468477ba54517157efa5021eaa6ff72f8f5c31e53d89f07d59071c0ae7 #2023-06-20

      [tools\7zxa.dll]
      SHA256 d88fe8b26519d30dbc1c754f5efa387b1f6f4f8035b197932c1442de77de0537 #2023-06-20

      [extras\busybox]
      SHA256 ccdb7753cb2f065ba1ba9a83673073950fdac7a5744741d0f221b65d9fa754d3

      [extras\app_manager]
      SHA256 504d761817e842580f89fbba46ecce6b57aba5116df159fff9c8ce0bb90ea18b

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
					if RegExMatch(A_LoopField, "\bMD2|MD5\b", hashtype) {
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
   global secure_user_info, general_log, HERE, TOOL, current, adb, fastboot
   GetFullPathName(to) ? to := GetFullPathName(to)
   if (to==current "\configs.ini") {
      MsgBox, 262144, Download Service, % " Attempting to replace:`n`n " to "`n`n This action is not allowed for your security"
      return 0
   }
   pid:=DllCall("GetCurrentProcessId")
   updating_script=
   (
   :destroy
   taskkill /F /PID %pid%
   del "%A_ScriptFullPath%"
   if exist "%A_ScriptFullPath%" goto destroy
   move "%to%" "%A_ScriptFullPath%"
   `(goto`) 2>nul & del "`%~f0" & cmd /c start "%A_ScriptFullPath%" "%A_ScriptFullPath%"
   )
   updating_script_zip=
   (
   :destroy
   taskkill /F /PID %pid%
   del "%A_ScriptFullPath%"
   if exist "%A_ScriptFullPath%" goto destroy
   move "%current%\update.exe" "%A_ScriptFullPath%"
   `(goto`) 2>nul & del "`%~f0" & cmd /c start "%A_ScriptFullPath%" "%A_ScriptFullPath%"
   )
   if (secure_user_info && !(to ~= "^((\Q" HERE "\E)|(\Q" TOOL "\E))")) {
      MsgBox, 262148, Download Service, % " Attempting to download a file outside of common paths:`n`n " to "`n`n Do you want to allow it?"
	  IfMsgBox No
	  {
	     return 0
	  }
   }
   if RegExMatch(option, "\bMD2|MD5\b", hashtype) {
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
   if (option ~= "i)\bupdate\b") {
      update=true
   } else if (option ~= "i)\bupdate_zip\b") {
      update_zip=true
   }
   if (option ~= "i)\bforce\b") {
      force=true
   }
   if hashtype {
      if update {
		 RegExMatch(read_xml("https://raw.githubusercontent.com/BlassGO/auto_img_request/main/hash.txt",, true), "\b[A-Fa-f0-9]{" checklen "}\b", hash)
		 if !force && (hash=get_hash(A_ScriptFullPath,hashtype)) {
			write_file("`n" A_ScriptName " already updated, skipping...`n", general_log)
			return 1
	     } else if !url {
           just_update:=true
        }
	  } else if update_zip {
        RegExMatch(read_xml("https://raw.githubusercontent.com/BlassGO/auto_img_request/main/hash.txt",, true), "\b[A-Fa-f0-9]{" checklen "}\b", hash)
        if !force && (hash=get_hash(A_ScriptFullPath,hashtype)) {
			write_file("`n" A_ScriptName " already updated, skipping...`n", general_log)
			return 1
	     } else {
          RegExMatch(read_xml("https://raw.githubusercontent.com/BlassGO/auto_img_request/main/hash_zip.txt",, true), "\b[A-Fa-f0-9]{" checklen "}\b", hash)
        }
     } else {
         RegExMatch(option, "\b[A-Fa-f0-9]{" checklen "}\b", hash)
	  }
	  if !hash {
	     MsgBox, % 262144 + 16, ERROR, % "No valid hash found for: " hashtype
		 return 0
	  }
   }
   if just_update {
      FileGetSize, bytes, % to
   } else {
      bytes := HttpQueryInfo(url, 5)
      if bytes is not integer
      {
         write_file("`n" wbasename(to) " download ended with: " bytes "`n", general_log)
         MsgBox, % 262144 + 16, ERROR, % "Oops! no response from download server, try again later"
         return 0
      }
   }
   if FileExist(to) {
      FileGetSize, currentbytes, % to
      if !force && (bytes=currentbytes) {
	     write_file("`n" basename(to) " already has " bytes " bytes, skipping...`n", general_log)
	     if hash {
		    if (hash=get_hash(to,hashtype)) {
			   write_file("`n" basename(to) " passed " hashtype " hash check, skipping...`n", general_log)
            gosub do_update
            return result
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
      MsgBox, % 262144 + 16, ERROR, % " Unable to download content: `n " url
	  result:=0
   } else {
      FileGetSize, currentbytes, % to
      if (bytes!=currentbytes) {
		 write_file("`n" basename(to) " has " currentbytes " of " bytes ", removing...`n", general_log)
		 FileDelete, % to
		 MsgBox, % 262144 + 16, ERROR, % """" wbasename(to) """ is corrupted (and was removed), please try again later "
		 result:=0
	  } else if hash {
	     if (hash=get_hash(to,hashtype)) {
			write_file("`n" basename(to) " passed " hashtype " hash check`n", general_log)
			gosub do_update
		 } else {
			write_file("`n" basename(to) " DID NOT pass " hashtype " hash check, removing...`n", general_log)
			FileDelete, % to
			MsgBox, % 262144 + 16, ERROR, % """" wbasename(to) """ did not pass the specified " hashtype " check and was removed"
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
   do_update:
            result:=1
            if update_zip {
               Process, Close, % basename(adb)
               Process, Close, % basename(fastboot)
               FileDelete, % current "\update.exe"
               if InStr(FileExist(current "\update.exe"), "A") {
				      anomaly:=true
               } else {
                  Loop, parse, % read_xml("https://raw.githubusercontent.com/BlassGO/auto_img_request/main/bin_tree.txt",, true), `n,`r 
                  {
                      if InStr(FileExist(current "\" A_LoopField), "D") {
                         FileRemoveDir, % current "\" A_LoopField, 1
                         if InStr(FileExist(current "\" A_LoopField), "D") {
                             MsgBox, % 262144 + 16, ERROR, % "Busy folder:`n`n" current "\" A_LoopField
                             result:=0
					              return
                         }
                      }
                  }
                  if unzip(to "\bin", current, "force inside-zip") && unzip(to, current, "files force regex: ^[^\\]+\.exe$") {
                     FileMove, % current "\*.exe", % current "\update.exe"
                     if InStr(FileExist(current "\update.exe"), "A") {
                        update:=true, updating_script:=updating_script_zip
                     } else {
                        anomaly:=true
                     }
                  } else {
                     anomaly:=true
                  }
               }
            }
			   if update {
				  FileDelete, % current "\killmeplz.bat"
				  if FileExist(current "\killmeplz.bat") {
				     anomaly:=true
				  } else {
					 FileAppend, % updating_script, % current "\killmeplz.bat"
					 Run, "%current%\killmeplz.bat", , Hide
					 gosub finish
				  }
			   }
            if anomaly {
               MsgBox, % 262144 + 16, ERROR, % "Anomaly was detected, please update the tool manually from an official site."
               gotolink("https://github.com/BlassGO/AutoIMG")
					result:=0
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
   adb_shell("setprop sys.usb.config mtp,adb; setprop sys.usb.ffs.mtp.ready 1")
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
	   MsgBox, % 262144 + 16, ERROR, The update function is not supported from fastboot
	   return 0
	}
	run_binary("dd") && dd := true
	run_binary("cat") && cat := true
	if !dd && !cat {
	   MsgBox, % 262144 + 16, ERROR, update: No available actions found on the device
	   return 0 
	}
    if !exist_file(img) {
	   MsgBox, % 262144 + 16, ERROR, % "Cant find " img " on the device"
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
   supdate=
   (
      if [ -n "%dd%" ] && dd if="%img%" of="%dest%"; then
         echo "%dest% updated successfully with dd"
      elif [ -n "%cat%" ] && cat "%img%" > "%dest%"; then
         echo "%dest% updated successfully with cat"
      else
         echo "ERROR: Cant install %img% in %dest%"
   )
   result:=sh(supdate)
   write_file(result, general_log)
	if InStr(result, "ERROR: ") {
	   print(">> Cant update " ubasename(img))
      MsgBox, % 262144 + 16, ERROR, % " Some problem updating " ubasename(img) " in " dest
	   return 0
	}
	return 1
}
update_push(img, dest, nofind := "") {
	TMP := ensure_tmp()
	if !TMP
	   return 0
    if !push(img, TMP)
       return 0
	if update(TMP "/" basename(img), dest, nofind) {
      adb_shell("rm -f """ TMP "/" basename(img) """")
	   return 1
	} else {
	   return 0
	}
}
get_cmdline(prop) {
   if !run_binary("cat") {
      MsgBox, % 262144 + 16, ERROR, get_cmdline: cat command not supported on device
	  return
   }
   get := Trim(adb_shell("temp=$(cat /proc/cmdline 2>/dev/null); try=${temp#*" prop "=}; if [ ""$temp"" = ""$try"" ]; then cat /proc/bootconfig 2>/dev/null; else echo ${try%% *}; fi"), "`n`r" A_Space "`t")
   if InStr(get, "`n") {
      get := RegExReplace(get, "(?:^\h*|.*\R\h*)\Q" prop "\E\h*=\h*(.*?)(?:\R|$).*", "$1", result)
      result ? get:=Trim(get, A_Space "`t") : get:=""
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
	   MsgBox, % 262144 + 16, ERROR, The get_slot function is not supported from fastboot
	   return
	}
   sslot=
   (
      temp=$(cat /proc/cmdline 2>/dev/null)
      for try in androidboot.slot_suffix androidboot.slot; do
         try=${temp#*$try=}
         if [ "$temp" != "$try" ]; then
            echo ${try`%`% *}
            exit
         fi
      done
      try=$(getprop ro.boot.slot_suffix 2>/dev/null)
      [ -n "$try" ] && echo $try || cat /proc/bootconfig 2>/dev/null 
   )
   slot := Trim(sh(sslot), "`n`r" A_Space "`t")
   if InStr(slot, "`n") {
      slot := RegExReplace(slot, "(?:^\h*|.*\R\h*)(?:\Qandroidboot.slot_suffix\E|\Qandroidboot.slot\E)\h*=\h*(.*?)(?:\R|$).*", "$1", result)
      (!result) ? slot:=""
   }
   if (slot:=Trim(slot, "`n`r" A_Space "`t")) && !InStr(slot, "_") {
      slot := "_" slot
   }
   return slot
}
find_block(name) {
   global exist_device, device_mode, serial, general_log, cache
   if (serial && !check_active(serial))
      return
   if (device_mode="fastboot") {
	   MsgBox, % 262144 + 16, ERROR, The find_block function is not supported from fastboot
	   return
	}
   if !IsObject(cache)
      optimize()
   if cache.parts.HasKey(name)
      return cache.parts[name]
   run_binary("find") && find := true
   slot := get_slot()
   if find {
	  try := adb_shell("if [ -e ""$(command -v head)"" ]; then part=$((find /dev/block \( -type b -o -type c -o -type l \) -iname " name " -o -iname " name slot " | head -n1) 2>/dev/null); elif [ -e ""$(command -v sed)"" ]; then part=$((find /dev/block \( -type b -o -type c -o -type l \) -iname " name " -o -iname " name slot " | sed -n ""1p;q"") 2>/dev/null); fi; [ -n ""$part"" -a -e ""$(command -v readlink)"" ] && echo $(readlink -f ""$part"") || echo $part", "", true)
	  try := Trim(try, "`n`r" A_Space "`t")
	  if try && exist_file(try) {
	     block := try
	  } else {
	     MsgBox, % 262144 + 16, ERROR, % "Cant find " name " partition"
	  }
   } else {
      MsgBox, % 262144 + 16, ERROR, find_block: find command not supported on device
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
	   MsgBox, % 262144 + 16, ERROR, The get_twrp_ramdisk function is not supported from fastboot
	   return 0
   }
   run_binary("cpio") && cpio := true
   if !cpio {
	   MsgBox, % 262144 + 16, ERROR, get_twrp_ramdisk: No available actions found on the device: cpio
	   return 0 
   }
   if !exist_file("/ramdisk-files.txt") {
      MsgBox, % 262144 + 16, ERROR, Your current Recovery does not support building ramdisk A/B
	  return 0
   }
   result := run_binary("cpio", "-H newc -o < /ramdisk-files.txt > " """" ramdisk """")
   write_file(result, general_log)
   return 1
   ; Possible evalaluation of errors coming soon
}
update_ramdisk(ramdisk, part := ""){
   global exist_device
   global device_mode
   global serial
   global general_log
   if (serial && !check_active(serial))
      return 0
   if (device_mode="fastboot") {
	   MsgBox, % 262144 + 16, ERROR, The update_ramdisk function is not supported from fastboot
	   return 0
   }
   run_binary("magiskboot") && magiskboot := true
   if !magiskboot {
	   MsgBox, % 262144 + 16, ERROR, Your current Recovery does not support boot.img building: magiskboot is needed
	   return 0 
   }
   if !exist_file(ramdisk) {
	   MsgBox, % 262144 + 16, ERROR, % "Cant find " ramdisk " on the device"
       return 0
   }
   TMP := ensure_tmp()
   if !TMP
	  return 0
   TMP := TMP "/update_0001"
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
   strymagisk=
   (
      if [ -f "%TMP%/kernel" ]; then
         MAGISK_ERROR=
         format=$(decompress kernel kernel_)
         [ -n "$format" ] && echo KERNEL with compression: $format || cp -f kernel kernel_
         rm -f kernel
         if [ -n "$NMAGISK_INSTALLED" ]; then
             magiskboot split kernel_
             if magiskboot hexpatch kernel_ 736B69705F696E697472616D6673 77616E745F696E697472616D6673; then
                if [ -n "$format" ]; then
                   magiskboot compress=$format kernel_ kernel
                else
                   cp -f kernel_ kernel
                fi
                echo MAGISK restored successfully in KERNEL
             else
                echo Kernel seems to need no changes for MAGISK, keeping stock kernel
                rm -f kernel
                rm -f kernel_
             fi
             if [ -f .magisk ]; then
                export $(cat .magisk)
                for fstab in dtb extra kernel_dtb recovery_dtbo; do
                    [ -f $fstab ] && magiskboot dtb $fstab patch
                done
             fi
         elif [ -n "$MAGISK_INSTALLED" ]; then
            if magiskboot hexpatch kernel_ 77616E745F696E697472616D6673 736B69705F696E697472616D6673; then
               if [ -n "$format" ]; then
                  magiskboot compress=$format kernel_ kernel
               else
                  cp -f kernel_ kernel
               fi
               echo MAGISK removed successfully in KERNEL
            else
               MAGISK_ERROR=true
               echo ERROR: Cant remove MAGISK from kernel
            fi
            
         else
            echo MAGISK not detected, keeping stock kernel
            rm -f kernel
            rm -f kernel_
         fi
         format=
      fi
   )
   sramdisk=
   (
      decompress() {
         try=$(magiskboot decompress "$1" "$2" 2>&1)
         f=${try#*format: [}
         f=${f`%`%]*}
         [ "$f" != "$try" -a "$f" != "raw" ] && echo $f
      }
      rm -rf "%TMP%"
      mkdir -p "%TMP%"
      if [ -d "%TMP%" ]; then
         cd "%TMP%" && magiskboot unpack -h -n "%boot%"
         if [ -f "%TMP%/ramdisk.cpio" ]; then
            format=$(decompress ramdisk.cpio ramdisk_.cpio)
            if [ -n "$format" ]; then
               magiskboot cpio ramdisk_.cpio test
               STATE=$?
            else
               magiskboot cpio ramdisk.cpio test
               STATE=$?
            fi
            [ $STATE = 1 ] && MAGISK_INSTALLED=true
            rm -f ramdisk.cpio
            rm -f ramdisk_.cpio
            if [ -n "$format" ]; then
               echo Ramdisk with compression: $format
               format2=$(decompress "%ramdisk%" ramdisk.cpio)
               if [ -n "$format2" ]; then
                  magiskboot cpio ramdisk.cpio test
                  NSTATE=$?
                  [ $NSTATE = 1 ] && magiskboot cpio ramdisk.cpio "extract .backup/.magisk .magisk"
                  magiskboot compress=$format ramdisk.cpio ramdisk_.cpio
               else
                  magiskboot cpio "%ramdisk%" test
                  NSTATE=$?
                  [ $NSTATE = 1 ] && magiskboot cpio "%ramdisk%" "extract .backup/.magisk .magisk"
                  magiskboot compress=$format "%ramdisk%" ramdisk_.cpio
               fi
            else
               format2=$(decompress "%ramdisk%" ramdisk_.cpio)
               [ -z "$format2" ] && cp -f "%ramdisk%" ramdisk_.cpio
               magiskboot cpio ramdisk_.cpio test
               NSTATE=$?
               [ $NSTATE = 1 ] && magiskboot cpio ramdisk_.cpio "extract .backup/.magisk .magisk"
            fi
            [ $NSTATE = 1 ] && NMAGISK_INSTALLED=true
            rm -f ramdisk.cpio
            cp -f ramdisk_.cpio ramdisk.cpio

            %strymagisk%

            [ -n "$MAGISK_ERROR" ] && exit
            if [ -f ramdisk.cpio ]; then
               magiskboot repack "%boot%"
               if [ -f new-boot.img ]; then
                  if dd if=new-boot.img of="%boot%" || cat new-boot.img > "%boot%"; then
                     echo Ramdisk updated successfully
                  else
                     echo "ERROR: Cant install boot.img in %boot%"
                  fi
               else
                  echo ERROR: Some problem building new boot.img
               fi
            else
               echo ERROR: Some problem updating new ramdisk
            fi
         else
            echo "ERROR: Some problem unpacking %boot_base%"
         fi
      else
         echo "ERROR: Cant create %TMP%"
      fi
   )
   print(">> Updating ramdisk: " boot_base)
   result:=sh(sramdisk)
   write_file(result, general_log)
   if InStr(result, "ERROR: ") {
	   MsgBox, % 262144 + 16, ERROR, Cant update ramdisk in %boot%
	   return 0
   }
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
	    MsgBox, % 262144 + 16, ERROR, The update_ramdisk_push function is not supported from fastboot
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
	   MsgBox, % 262144 + 16, ERROR, The update_ramdisk function is not supported from fastboot
	   return 0
   }
   run_binary("magiskboot") && magiskboot := true
   if !magiskboot {
	   MsgBox, % 262144 + 16, ERROR, Your current Recovery does not support kernel updating
	   return 0 
   }
   if !exist_file(kernel) {
	   MsgBox, % 262144 + 16, ERROR, % "Cant find " kernel " on the device"
       return 0
   }
   TMP := ensure_tmp()
   if !TMP
	  return 0
   TMP := TMP "/update_0001"
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
   skernel=
   (
      decompress() {
         try=$(magiskboot decompress "$1" "$2" 2>&1)
         f=${try#*format: [}
         f=${f`%`%]*}
         [ "$f" != "$try" -a "$f" != "raw" ] && echo $f
      }
      rm -rf "%TMP%"
      mkdir -p "%TMP%"
      if [ -d "%TMP%" ]; then
         cd "%TMP%" && magiskboot unpack -h -n "%boot%"
         if [ -f "%TMP%/kernel" ]; then
            if [ -f "%TMP%/ramdisk.cpio" ]; then
               format=$(decompress ramdisk.cpio ramdisk_.cpio)
               if [ -n "$format" ]; then
                  magiskboot cpio ramdisk_.cpio test
                  STATE=$?
                  [ $STATE = 1 ] && magiskboot cpio ramdisk_.cpio "extract .backup/.magisk .magisk"
               else
                  magiskboot cpio ramdisk.cpio test
                  STATE=$?
                  [ $STATE = 1 ] && magiskboot cpio ramdisk.cpio "extract .backup/.magisk .magisk"
               fi
               [ $STATE = 1 ] && MAGISK_INSTALLED=true
               rm -f ramdisk.cpio
               rm -f ramdisk_.cpio
               format=
            fi
            format=$(decompress kernel kernel_)
            rm -f kernel
            rm -f kernel_    
            format2=$(decompress "%kernel%" kernel_)
            [ -z "$format2" ] && cp -f "%kernel%" kernel_
            if [ -n "$MAGISK_INSTALLED" ]; then
               magiskboot split kernel_
               if magiskboot hexpatch kernel_ 736B69705F696E697472616D6673 77616E745F696E697472616D6673; then
                  echo MAGISK restored successfully in NEW KERNEL
               else
                  echo NEW KERNEL seems to need no changes for MAGISK
               fi
               if [ -f .magisk ]; then
                  export $(cat .magisk)
                  for fstab in dtb extra kernel_dtb recovery_dtbo; do
                     [ -f $fstab ] && magiskboot dtb $fstab patch
                  done
               fi
            else
               echo MAGISK not detected, no additional patches required
            fi
            if [ -n "$format" ]; then
               echo KERNEL with compression: $format
               magiskboot compress=$format kernel_ kernel
            else
               cp -f kernel_ kernel
            fi
            if [ -f kernel ]; then
               magiskboot repack "%boot%"
               if [ -f new-boot.img ]; then
                  if dd if=new-boot.img of="%boot%" || cat new-boot.img > "%boot%"; then
                     echo Kernel updated successfully
                  else
                     echo "ERROR: Cant install boot.img in %boot%"
                  fi
               else
                  echo ERROR: Some problem building new boot.img
               fi
            else
               echo ERROR: Some problem updating new kernel
            fi
         else
            echo "ERROR: Some problem unpacking %boot_base%"
         fi
      else
         echo "ERROR: Cant create %TMP%"
      fi
   )
   print(">> Updating kernel: " boot_base)
   result:=sh(skernel)
   write_file(result, general_log)
   if InStr(result, "ERROR: ") {
	   MsgBox, % 262144 + 16, ERROR, Cant update kernel in %boot%
	   return 0
   }
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
	    MsgBox, % 262144 + 16, ERROR, The update_kernel_push function is not supported from fastboot
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
	    MsgBox, % 262144 + 16, ERROR, The install_recovery_ramdisk function is not supported from fastboot
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
	   MsgBox, % 262144 + 16, ERROR, The decompress function is not supported from fastboot
	   return
   }
   run_binary("magiskboot") && magiskboot := true
   if !magiskboot {
	   MsgBox, % 262144 + 16, ERROR, Cant find magiskboot
	   return
   }
   if !exist_file(file) {
	   MsgBox, % 262144 + 16, ERROR, % "Cant find " file " on the device"
       return
   }
   base := "magiskboot decompress " """" file """"
   if dest
      base .= " " """" dest """"
   try := adb_shell(base)
   if !(try ~= "\braw\b"){
      format := Trim(RegExReplace(try, "(?:^|.*\R).*format: \[(.+?(?=\])).*", "$1",result), A_Space)
      (!result) ? format:=""
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
	   MsgBox, % 262144 + 16, ERROR, The recompress function is not supported from fastboot
	   return 0
   }
   run_binary("magiskboot") && magiskboot := true
   if !magiskboot {
	   MsgBox, % 262144 + 16, ERROR, Cant find magiskboot
	   return 0
   }
   if !exist_file(file) {
	   MsgBox, % 262144 + 16, ERROR, % "Cant find " file " on the device"
       return 0
   }
   base := "magiskboot compress=" format " " """" file """"
   if dest
      base .= " " """" dest """"
   base .= " && echo Success"
   result := adb_shell(base)
   if !InStr(result, "Success"){
      write_file(result, general_log)
      MsgBox, % 262144 + 16, ERROR, % "Some problem compressing " file " as " format
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
		 MsgBox, % 262144 + 16, ERROR,  % "Cant open link: `n`n" link
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
install(file, in, with:="") {
   global install_files
   (!IsObject(install_files)) ? install_files:=[]
   if !InStr(FileExist(file), "A") {
      unexpected := "Cant find file: " file
	   return 0
	}
   in:=Trim(in)
   (in="ZIP FILE") ? is_zip:=true
   (in="RAMDISK FILE") ? is_ramdisk:=true
	try {
      install_files.Push({file:file, part:in, extra:Trim(with), is_zip:is_zip, is_ramdisk:is_ramdisk, install:true})
	} catch {
      unexpected := "Cant append file: " file
      return 0
	}
	return 1
}
unlock(){
   global secure_user_info, skip_functions
   if question("Unlock","Do you want to disable all security during installation?`n`nNOTE: This is not necessarily unsafe if the Script is from a trusted source.") {
      secure_user_info:="",skip_functions:=""
      return 1
   } else {
     return 0
   }
}
wipe_env(reset := false) {
   global install_files
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
      MsgBox, % 262144 + 16, ERROR, % "Cant find file: " file
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
Gui, Add, Tab2, x%mx% Y+10 vtabs hwndtabshw Group +Theme -Background,, Home|Actions|Settings|Wifi|Info
Gui, Tab, 1
Gui, Add, GroupBox, x%mx% Y+5 h%boxH% w%boxW% c254EC5, Build: %build_author%/%build_date%
Gui, Add, Text, YP+30 XP+10 Section, Select installation file:
Gui, Add, Button, center X+13 YP h20 w100 gselect, Select File
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
Gui, Tab, 2
Gui, Font, s10, Arial Black
Gui, Add, GroupBox, x%mx% Y+5 h%boxH% w%boxW% c254EC5 Section, Reboot
Gui, Font, s10, %style%
Gui, Add, Button, center XP+10 YP+30 h40 w80 0x200 border gonly_reboot vonly_reboot, Reboot
Gui, Add, Button, center X+10 YP h40 w80 0x200 border greboot_fastboot vreboot_fastboot, Fastboot(D)
Gui, Add, Button, center X+10 YP h40 w80 0x200 border greboot_recovery, Recovery
Gui, Font, s10, Arial Black
Gui, Add, GroupBox, XS Y+10 h%boxH% w%boxW% c254EC5, Extra Actions
Gui, Font, s10, %style%
Gui, Add, Text, XP+10 YP+30 Section, Remove bloatware:
Gui, Add, Text, XP Y+30, Extract-send files: 
Gui, Add, Text, XP Y+30, Open the console: 
Gui, Font, s10, Arial Black
Gui, Add, Text, XS+130 YS c254EC5, -►
Gui, Add, Text, XP Y+30 c254EC5, -►
Gui, Add, Text, XP Y+30 c254EC5, -►
Gui, Font, s10, %style%
Gui, Add, Button, center X+5 YS-10 h40 w100 gapp_manager, App Manager
Gui, Add, Button, center XP Y+10 h40 w100 gfile_manager, File Manager
Gui, Add, Button, center XP Y+10 h40 w100 guser_console, Console
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
Gui, Add, GroupBox, x%mx% Y+5 h%boxH% w%boxW% c254EC5 Section, Remote Script
Gui, Font, s10, %style%
Gui, Add, Text, YP+30 XP+10 , Run a Config-Script from a URL:
Gui, Font, s10, Arial Black
Gui, Add, Edit, center XP YP+20 h20 w260 vfromurl hwndfromurlid,
Gui, Font, s10, %style%
Gui, Add, Button, center XP+75 Y+10 h40 w100 gfromurl, Run
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
Gui, Add, Text, YP+30 XP+10 Section, Multipurpose ADB-Fastboot Tool
Gui, Add, Button, center X+10 YP-10 h40 gcheck_update, Check`nupdates
Gui, Add, Text, YS+30 XS+10 cgreen Section, Tool Name:
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
OnMessage(WM_COMMNOTIFY := 0x44, "eventHandler") 
CtlColor_Edit(fromurlid,0xE4F4F4, 0x12A1A1)
OnExit, GuiClose
enable_bar()
disable_bar()
gosub update_preferences
print(">> Integrity: Checking...")
check_bin()
print(">> Integrity: Success")
secure_user_info:=""
return

check_update:
web_config("https://raw.githubusercontent.com/BlassGO/auto_img_request/main/support.config", 3000, true)
load_config(,,,,,true)
return

user_console:
    console(,{1:adb, 2:fastboot})
return

app_manager:
   if !exist_device {
	    MsgBox, % 262144 + 64, HELP, First find your device
   } else {
       app_manager(file)
   }
return

file_manager:
   if !exist_device {
	    MsgBox, % 262144 + 64, HELP, First find your device
   } else {
       file_manager()
   }
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
	   MsgBox, % 262144 + 16, HELP, % "Invalid IP: """ ip """"
	   return
	}
	if !(port ~= "^\d+$") {
	   MsgBox, % 262144 + 16, HELP, % "Invalid PORT: """ port """"
	   return
	}
	IniRead, preferences, % current "\configs.ini", GENERAL, preferences, 0
	if (preferences=1) {
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

fromurl:
   Gui, 1:Submit, NoHide
   if fromurl {
      IniRead, preferences, % current "\configs.ini", GENERAL, preferences, 0
      if (preferences=1) {
         IniWrite, %fromurl%, % current "\configs.ini", GENERAL, fromurl
      }
      web_config(fromurl, 3000, true)
      load_config(,,,,,true)
   }
return

clean:
	wipe_env(true)
	ToolTip, Cleaning Configs...
	SetTimer, RemoveToolTip, -1000
return

donate:
	Run, https://paypal.me/blassgohuh?country.x=EC&locale.x=es_XC
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
		IniRead, fromurl, % current "\configs.ini", GENERAL, fromurl, 0
		IniRead, port, % current "\configs.ini", GENERAL, port, 5555
      (!ip) ? ip:=""
      (!fromurl) ? fromurl:=""
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
      GuiControl, 1:, fromurl, %fromurl%
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
	(!ext) ? ext := "*.img;*.config;*.zip;*.apk;*.cpio;*.aid"
	if (part && part!="None") && (install_files[install_files.MaxIndex()].part!=part) {
      install_files[install_files.MaxIndex()].part := part
   }
	FileSelectFile, file, 1,, Please select some IMG to Install, (%ext%)
	if !file {
	  print(">> Warning: No Selection")
	} else {
	  ext := extname(file)
	  if (ext="zip"||ext="apk") {
       if (ext="zip") && check_content("on_install.config",file) {
          print(">> Loaded Config: " + basename(file))
          on_install(file,true)
       } else {
         print(">> Loaded ZIP: " + basename(file))
         GuiControl, 1:, partition, ZIP FILE
         install(file, "ZIP FILE")
         if (zip_msg!=1) {
            help(current "\images\recoverys.png", "The installation of ZIPs requires a Custom Recovery (Or device Booted + Root), so`nAll loaded ZIPs will be installed after the IMGs and not in load order")
            IniWrite, 1, % current "\configs.ini", GENERAL, zip_msg
         }
       }
	  } else if (ext="config") {
		 print(">> Loaded Config: " + basename(file))
		 read_config(file)
     } else if (ext="cpio") {
       print(">> Loaded RAMDISK: " + basename(file))
		 GuiControl, 1:, partition, RAMDISK FILE
		 install(file, "RAMDISK FILE")
     } else if (ext="aid") {
       switch (SubStr(ObjHeader(file),0))
       {
         case "A":
            gosub app_manager
         case "I":
            install_manager(file)
       }
	  } else {
		 print(">> Loaded: " + basename(file))
		 GuiControl, 1:, partition, % simplename(file)
		 install(file, simplename(file))
	  }
     file:=""
	}
return

only_reboot:
   Gui, 1:Submit, NoHide
	if (serial && !check_active(serial))
	   return
	if !exist_device {
	    MsgBox, % 262144 + 64, HELP, First find your device
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
	    MsgBox, % 262144 + 64, HELP, First find your device
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
	  MsgBox, % 262144 + 64, HELP, First find your device
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
	  MsgBox, % 262144 + 64, HELP, First find your device
	  return
	}
	if (part && part!="None") && (install_files[install_files.MaxIndex()].part!=part) {
	   install_files[install_files.MaxIndex()].part := part
	}
	to_install=0
   to_install_zip=0
   to_install_ramdisk=0
   for index, file in install_files {
      if file.install {
         if file.is_zip {
            to_install_zip++
         } else if file.is_ramdisk {
            to_install_ramdisk++
         } else {
			   to_install++
         }
      }
   }
   while (to_install_ramdisk>1)&&!question("HUH","Do you really want to install more than one Ramdisk?") {
         MsgBox, % 262144 + 64, HELP, Okay, disable unwanted Ramdisks
         install_manager()
         to_install_ramdisk=0
         for index, file in install_files {
            if file.install && file.is_ramdisk
               to_install_ramdisk++
         }
   }
   if to_install_ramdisk && (!isObject(cache)||cache.parts.HasKey("recovery")) {
      ramdisk_dest:=Option("Ramdisk dest","The Ramdisk can be installed in Boot or in Recovery`n`nWhat do you prefer?","In Boot partition (New devices)", "In Recovery partition (Old devices)")
      if !ramdisk_dest {
         print(">> Aborted Ramdisk Installation!")
         return
      }
   } else {
      ramdisk_dest:=1
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
	if !(to_install||to_install_zip||to_install_ramdisk||to_remove||to_create) && (format_data!=1) {
	  MsgBox, % 262144 + 64, HELP, Please enable at least one action/installation
	  return
   } else if !to_install && to_install_ramdisk {
      goto ramdisk_install
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

ramdisk_install:
   if !install_fail {
      if to_install_ramdisk {
         disable_bar()
         FD_CURRENT ? load_config("section ""before_ramdisk""",,, FD_CURRENT)
         enable_bar()
         PATH := PATH ? PATH . ":/data/adb/magisk" : "/data/adb/magisk"
         if (device_mode!="booted"&&device_mode!="recovery") {
             option:=Option("Reboot menu", "Your device must be Booted or in Recovery mode for Ramdisk Installation`n`nWhat do you prefer?", "Reboot in Recovery", "Normal reboot")
             if (option=1)
                gosub reboot_recovery
             else if (option=2)
                gosub only_reboot
             else {
                print(">> Aborted Ramdisk Installation!")
                return
             }
             print(">> Waiting device")
             if !find_device(20) {
                print(">> Oops! device not found"), disable_bar()
                return
             }
         }
         print(">> Loading RAMDISK installation")
         print(">> Magiskboot? ",false)
         if run_binary("magiskboot") {
            print("YEAH")
         } else {
            MsgBox, % 262144 + 16, ERROR, You did not install MAGISK on your device, it is needed for Ramdisk patching
            print("NAO"), disable_bar()
            return
         }
         if (ramdisk_dest=1) {
            print(">> A/B? ",false)
            (slot:=get_slot()) ? print("YEAH") : print("NAO")
         }
         if !(TMP:=ensure_tmp()) {
            print(">> Aborted Ramdisk Installation!"), disable_bar()
            return
         }
         progress := Round(100/to_install_ramdisk)
         for index, file in install_files {
            if file.install&&file.is_ramdisk {
               if !push(file.file, TMP . "/update_ramdisk") {
                  install_fail := true
                  break
               }
               in_file:=TMP . "/update_ramdisk/" . basename(file.file)
               if (ramdisk_dest=1) {
                  if (slot&&update_ramdisk(in_file,"boot_a")&&update_ramdisk(in_file,"boot_b")) || (!slot&&update_ramdisk(in_file,"boot"))  {
                     add_progress(progress)
                  } else {
                     install_fail := true
                     break
                  }
               } else if update_ramdisk(in_file,"recovery") {
                  add_progress(progress)
               } else {
                  install_fail := true
                  break
               }
            }
         }
         disable_bar()
         if install_fail {
            print(">> Aborted Ramdisk Installation!")
            return
         }
         FD_CURRENT ? load_config("section ""after_ramdisk""",,, FD_CURRENT)
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
         if install_fail {
            print(">> Aborted ZIP Installation!")
            return
         }
         FD_CURRENT ? load_config("section ""after_zip""",,, FD_CURRENT)
	   }
      FD_CURRENT ? load_config("section ""after_all""",,, FD_CURRENT)
      if (reboot=1) {
         FD_CURRENT ? load_config("section ""before_reboot""",,, FD_CURRENT)
         gosub only_reboot
         FD_CURRENT ? load_config("section ""after_reboot""",,, FD_CURRENT)
      }
      FD_CURRENT ? load_config("section ""after""",,, FD_CURRENT)
      print(">> Done")
   }
return

finish:
GuiEscape:
GuiClose:
   if !toolclosed&&cmdpid {
      MsgBox, % 262144 + 4 + 32, WARNING, There are processes running`n`nDo you want to force them to terminate?
      IfMsgBox, No
        return
      DllCall("FreeConsole")
      Process, Close, % cmdpid
      Run, taskkill /F /PID %cmdpid%, , Hide
   }
   (!toolclosed) ? AnimateWindow(toolid, 500, EXIT_ANIM)
   toolclosed:=true
	ExitApp