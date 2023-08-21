;=======================================================================================
;
; Function:			load_config (DinoCode Interpreter)
; Description:		Run DinoCode from a string.
; Return value:		Depending on the resolution of the code it can return a string, a number, or an object.
;
; Author:           BlassGO
;
;=======================================================================================
;   Useful initial concepts:
;                 FD:                 A static Array, where each element corresponds to an "DObj" Object that will store the local variables of DinoCode
;                                       (The first FD is used for "main" and always exists, additional FDs are generally used during the execution of sections (TAGs), and are always destroyed).
;
;   Definitions:
;                 GLOBAL:             Global object that stores global DinoCode definitions
;                                       (Its elements are shared with all existing FDs).
;				  unexpected:         Global String that, when defined from any function, stops the execution of DinoCode and an Error message is built with this exception
;				                        (and additional information).
;                 FD_CURRENT:         Global integer with the identifier of the FD in use
;                                       (It is also a marker when DinoCode is running).
;
;	OnError("RuntimeError"):
;                 A safe to display an Error message at runtime, since it is possible to overload AHK during the evaluation of long expressions.
;
;   ConfigRC:
;                 A function to define native DinoCode variables
;                   (Customizable according to needs).
;
;   Extra functions:
;                 print:              This function must be modified to coexist with the main program
;                                        (Otherwise it won't work).
;                 NOTE:               The "option/help/input" functions use GUI identifiers: new, new2 and new3 respectively (also okay, okay2 and okay3 labels), therefore they are reserved and reuse in the main program is not recommended.
;
;                 
;   lang function:
;                 It consists of several groups/objects with respective identifiers and allows Functions, Connectors or Conditionals to have several possible nicknames,
;                   nicknames must be standardized without diacritics, since these disappear during processing.
;
;   maps function:
;                 It is a group/object that serves to define the semantics or syntax of the sentences, being able to play with Connectors in order to build a standardized list of parameters that will be sent to the respective function.
;                    
;                     EXAMPLE--->  option: {option: {max:2, at:"1,2", atpos:true}, with: {support:true, expand:true, at:3}}
;                     
;                     EXPLAIN----> The main "option" object is the container for all the specifications that the "option" sentence must meet, this includes specifications for both the function itself and its connectors.
;
;                                     max:         Limit of parameters that can receive.
;                                     support:     Special for Connectors, it should always be used to specify that the main action supports that connector.
;                                     literal:     Enables the use of literal arguments, a literal argument does not require Quotes/Delimiter (Similar to a number), BUT, it cannot contain spaces or have the same name of any Connector.
;                                     atpos:       Enables the use of positioning "at" for all Connectors (must be defined in the main Action).
;                                     at:          It establishes in which position the received parameters should be placed before being sent to the function (Positions that have not been covered use empty references, avoiding errors).
;                                     expand:      Enables adding in queue any number of parameters that are received, if combined with "at" it is possible to specify that from N position all the parameters received by the Connector must be added.
;                                     concat:      Indicates that all parameters received by the Connector where "concat" was defined must be added directly to the specified action or connector (without overwriting)
;                                                      EXAMPLE---> option: {option: {max:5}, with: {support:true, concat:"option"}}
;                                                      EXPLAIN---> All the parameters of the "with" connector will be concatenated in queue to those existing in "option", that is, if "option" has 3 parameters, and "with" receives 2 additional ones, they will be added in positions 4 and 5, total: 5 parameters for the "option" function.
;
;                                     ignore_func:  Avoid taking the main action as a function, even if it is (must be defined in the main Action).
;
;   load_config function:
;                configstr:        Code to execute (String).
;                local:            Enable Local work (The code will be executed in a new temporary FD, simulating a local execution).
;                local_obj:        When "local" is enabled, here you can send an additional Object that will be merged with the new local FD (Predefined variables for the new local space).
;                from_fd:          The identifier of any existing FD from which the code should be executed (By default, it works on the first FD).
;                from_type:        Especially used to identify special sections of code.
;                newmain:          If enabled, the entire work environment will be reset, leaving everything ready for the execution of a new Script
;                                     (It must always be used to end the execution of the entire Script, otherwise all the variables defined in the Script will be kept in memory, waiting for the execution of more code).
;                   
;=======================================================================================
; Security restrictions
; 
; skip_vars and skip_functions are Regex that specify which Functions cannot be called during the execution of DinoCode, and which Variables cannot be modified (Simulating Read Only access)
; shared_vars is a Regex that allows access to global variables, the first part "^(A_" ensures access to all AHK Native Variables (they always start with A_)
; If the same global variable is specified in both shared_vars and skip_vars, it implies that the global variable can be read but NOT modified.
;
    global skip_functions := "i)(^(load_config|FileOpen|ParseObjects|AssignParse|DllCall|ComObj|Obj|Func|Expr|read_config))|(Object)"
	global skip_vars := "i)^(skip_functions|skip_vars|shared_vars|true|false|verdadero|falso|secure_user_info|FD_CURRENT|version|build_date|winver|general_log|exitcode|GLOBAL|unexpected|current|tools|extras|HERE|TOOL|TMP|CONFIG|serial|currentdevice|device_mode|device_connection|exist_device|unlocked|fastbootd|current_slot|current_anti)$"
	global shared_vars := "i)^(A_|(FD_CURRENT|version|build_date|winver|general_log|exitcode|CONFIG|HERE|TOOL|TMP|PATH|serial|formats|currentdevice|device_mode|device_connection|exist_device|hidden_devices|unlocked|fastbootd|current_slot|current_anti|wireless_IP|wireless_PORT|wireless_FORCE)$)"
;
;=======================================================================================
SetBatchLines -1

; Definitions
global GLOBAL:={}, unexpected, FD_CURRENT
OnError("RuntimeError")
OnMessage(KeyDown:=0x100, "__DinoEvent__")

; ConfigRC
config_rc() {
   global secure_user_info, CONFIG, HERE, TOOL, PATH:="", formats:=""
   global wireless_IP:="", wireless_PORT:="", hidden_devices:="", wireless_FORCE:="", serial
   ; Native
   GLOBAL.false:=0, GLOBAL.true:=1, GLOBAL.verdadero:=1, GLOBAL.falso:=0
   ; Extra
   CONFIG ? HERE:=dirname(CONFIG) : HERE:=A_ScriptDir, TOOL:=A_ScriptDir, secure_user_info:=true
   wipe_env()
}

; Event control
__DinoEvent__(wParam, lParam, msg, hwnd) {
	static Enter:=0x0D
	if (wParam=Enter)&&(gui:=(A_Gui="new"||A_Gui="new2"||A_Gui="new3") ?  A_Gui : false) {
	   Gui, % gui ":Submit", NoHide
       Gui, % gui ":Destroy"
	}
	return 
}
__DinoGui__(Hwnd,GuiEvent,EventInfo,ErrLevel:="")
{
    GuiControlGet, _var, % A_Gui ":Name", % Hwnd
	_var ? gui(,_var)
}

; AutoIMG Functions
update_key(key,state:="") {
   GuiControl, 1:Choose, % key, % state
   if ErrorLevel {
      GuiControl,1:, % key, % state
	  return ErrorLevel
   }
   return 1
}

; Extra functions

; The print function needs to be adapted to the program, in this case it uses EditBox with an ID "generalbox" as the output of the prints.
; Example:
;         Gui, Add, Edit, h100 w250 hwndgeneralbox 0x200 border HScroll ReadOnly, >> Welcome to console`r`n
;
; Another more portable option is to include the console.ahk plugin and remove this print function

print(str,newline:=true,option:="") {
   global generalbox
   GuiControl, 1:choose, tabs, 1
   newline ? str.="`r`n"
   SendMessage, EM_GETLINECOUNT:=0x00BA, 0, 0, , ahk_id %generalbox%
   last:=ErrorLevel
   if (last>=100)
      GuiControl, 1:, console,
   if option && (option="r"||option="o") {
      SendMessage, EM_LINEINDEX:=0x00BB, last - 1, 0, , ahk_id %generalbox%
	  index:=ErrorLevel,extra:=0
      if (option="o") {
	     SendMessage, EM_LINELENGTH:=0x00C1, index, 0, , ahk_id %generalbox%
		 extra:=ErrorLevel
	  }
	  SendMessage, EM_SETSEL:=0x00B1, index, index+extra, , ahk_id %generalbox%
   } else {
      SendMessage, EM_SETSEL:=0x00B1, -2, -1, , ahk_id %generalbox%
   }
   SendMessage, EM_REPLACESEL:=0x00C2, false, &str, , ahk_id %generalbox%
   ;SendMessage, EM_SCROLLCARET:=0x00B7, 0, 0, , ahk_id %generalbox%
   ;ControlSend, , ^{End}, ahk_id %generalbox%
   return 1
}
read_file(file,enc:="") {
   (!enc) ? enc:="UTF-8"
   try {
      FileEncoding, % enc
      FileRead, content, % file
   } catch {
      unexpected:="Cant read-->""" file """, Ended with: " ErrorLevel
   }
   return content
}
wait_window(id) {
   WinWaitClose % id
   return 1
}
sleep(n) {
   if n is integer
      Sleep, n
   return 1
}
msg(title,d:=262144,msg:="") {
   try
      MsgBox, % d, % title, % msg
   catch
      return 0
   return 1
}
inmsg(as){
   IfMsgBox % as
      return 1
   return 0
}
question(title:="",q:="") {
   (!title) ? title:="Question"
   MsgBox, 262148, % title, % q
   IfMsgBox Yes
      return 1
   return 0 
}
press(key) {
   if isLabel(key) {
      try
         gosub % key
	  catch
	     return 0
   } else {
      unexpected:="Unrecognized button: " . key
	  return 0
   }
   return 1
}
gui(do:="",onevent:="",reset:=false) {
   static
   local args:=0, _label, _var, _random
   (reset||!isObject(labels)) ? (labels:={},vars:=[])
   if do {
	   do:=StrSplit(do,",",,4), args:=do.MaxIndex()
	   for cont, value in do
		  do[cont]:=Trim(value)
	   try {
		   StringCaseSense, Off
		   if (args=1) {
			  if (_at:=InStr(do[1],"return"))&&(_return:=Trim(SubStr(do[1],_at+6)))
				 return _return:=%_return%
		   }
		   if (args>=3) {
		      RegexMatch(do[3],"v\K\S+",_var) ? (GLOBAL[_var]:="",vars.Push(_var))
			  if RegexMatch(do[3],"g\S+",_label) {
			     if !_var {
				    Random, _random, 1, 100
				    _var:="_v" . _random . "v_", do[3].=" v" . _var
                 }
				 do[3]:=StrReplace(do[3],_label,"g__DinoGui__",, 1), labels[_var]:=SubStr(_label,2)
			  }
		   }
		   Gui, % do[1], % do[2], % do[3], % do[4]
		   RegexMatch(do[3],"hwnd\K\S+",_var) ? (GLOBAL[_var]:=%_var%)
		   if InStr(do[1],"submit")
		      for cont, value in vars
                  GLOBAL[value]:=%value%, %value%:=""
	   } catch e {
		   unexpected:=e.message
	   }
   } else if onevent && labels.HasKey(onevent){
       load_config(labels[onevent],,, FD_CURRENT, "resolve")
   }
   return
}
option(title,txt,options*) {
   static multi, okay
   (!title) ? title:="Option"
   Gui new: +AlwaysOnTop
   Gui new: Font, s10
   if txt
      Gui new: Add, Text, Y+0, % txt
   for count, value in options {
       if (count=1)
	      Gui new: Add, Radio, AltSubmit vmulti XP Y+10, % value
	   else
          Gui new: Add, Radio, , % value
   }
   Gui new: Add, Button, XS Y+10 h20 w100 vokay gokay, OKAY
   Gui new: Show, AutoSize Center, % title
   GuiControl, new: Move, okay, x%okay_x%
   WinWaitClose, % title
   return multi
   newGuiClose:
   okay:
   Gui new: Submit, NoHide
   Gui new: Destroy
   return
   newGuiSize:
   okay_x:=(A_GuiWidth - 100) // 2
   okay_y:=(A_GuiHeight - 20) // 2
   return
}
input(txt:="",w:="",h:=""){
   Static input, okay2
   (!(h~="[0-9]+")) ? h:=20
   if (w~="[0-9]+") {
      w:="w" . w
   } else if !txt {
      w:="w300"
   } else {
      w:="WP"
	  (StrLen(txt)<30) ? w:=w . "+60"
   }
   Gui new2: -MinimizeBox +AlwaysOnTop
   Gui new2: Font, s10
   if txt
      Gui new2: Add, Text, Y+0, % txt
   Gui new2: Add, Edit, % "XS Y+10 " . w . " h" . h . " vinput",
   Gui new2: Add, Button, XS Y+10 h20 w100 vokay2 gokay2, OKAY
   Gui new2: Show, AutoSize Center, Input
   GuiControl, new2: Move, okay2, x%okay_x%
   WinWaitClose, Input
   Gui new2: Destroy
   return input
   new2GuiClose:
   okay2:
   Gui new2: Submit, NoHide
   Gui new2: Destroy
   return
   new2GuiSize:
   okay_x:=(A_GuiWidth - 100) // 2
   okay_y:=(A_GuiHeight - 20) // 2
   return
}
help(image:="",txt:="") {
   static okay3, pic
   if image&&!InStr(FileExist(image), "A")
      return 0
   Gui new3: -MinimizeBox +AlwaysOnTop
   Gui new3: Font, s10
   if txt
      Gui new3: Add, Text, Y+0, % txt
   if image
      Gui new3: Add, Picture, XS Y+10 vpic, % image
   Gui new3: Add, Button, center XS Y+10 h20 w100 vokay3 gokay3, OKAY
   Gui new3: Show, AutoSize Center, HELP
   GuiControl, new3: Move, okay3, % "x" . (guiw - 100) // 2
   if image {
      GuiControlGet, size, new3: Pos, pic
      GuiControl, new3: Move, pic, % "x" . (guiw - sizeW) // 2
   }
   WinWaitClose, HELP
   okay3:
   Gui new3: Destroy
   return
   new3GuiSize:
   guiw:=A_GuiWidth
   guih:=A_GuiHeight
   return
}

; Classes
class DObj
{
    __New(parse:="",may:="") {
	    if IsObject(parse) {
          for key, value in parse
             this[key]:=value
		} else if parse {
		  if may {
		     this[parse]:=may
		  } else {
		     this[parse]:={}
		  }
		}
    }
    __Get(key) {
        if GLOBAL.HasKey(key)
           return GLOBAL[key]
		else if (key~=shared_vars)&&isSet(%key%) {
		   return __tmp:=%key%
		}
    }
	__Set(key, value) {
        if GLOBAL.HasKey(key) {
            GLOBAL[key]:=value
			return
		} else if (key~=shared_vars)&&!(key~=skip_vars) {
			%key%:=value
			return
		}
    }
	HasKey(key) {
        return ObjHasKey(GLOBAL,key)||ObjHasKey(this,key)||((key~=shared_vars)&&isSet(%key%))
    }
	global(key) {
		GLOBAL[key]:=this[key]
		this.Delete(key)
	}
}
class Thread {
    __New(fn,t,args*) {
        this.fn:=Func(fn)
        this.args:=args
        SetTimer, % this, % t
    }
    Call() {
        this.fn.Call(this.args*)
    }
	Parse(arg){
		SetTimer, % this, % arg
	}
}

; Main functions
LineStr(ByRef S, P, C:="", D:="") {   ;  LineStr v0.9d,   by SKAN on D341/D449 @ tiny.cc/linestr
Local L := StrLen(S),   DL := StrLen(D:=(D ? D : Instr(S,"`r`n") ? "`r`n" : "`n") ),   F, P1, P2 
Return SubStr(S,(P1:=L?(P!=1&&InStr(S,D,,0))?(F:=InStr(S,D,,P>0,Abs(P-1)))?F+DL:P-1<1?1:0:(F:=1)
:0),(P2:=(P1&&C!=0)?C!=""?(F:=InStr(S,D,,(C>0?F+DL:0),Abs(C)))?F-1:C>0?L:1:L:0)>=P1?P2-P1+1:0)
}
StrUnmark(string) {    ; By Lexicos
    len := DllCall("Normaliz.dll\NormalizeString", "int", 2
        , "wstr", string, "int", StrLen(string)
        , "ptr", 0, "int", 0)  ; Get *estimated* required buffer size.
    Loop {
        VarSetCapacity(buf, len * 2)
        len := DllCall("Normaliz.dll\NormalizeString", "int", 2
            , "wstr", string, "int", StrLen(string)
            , "ptr", &buf, "int", len)
        if len >= 0
            break
        if (A_LastError != 122) ; ERROR_INSUFFICIENT_BUFFER
            return
        len *= -1  ; This is the new estimate.
    }
    ; Remove combining marks and return result.
    return RegExReplace(StrGet(&buf, len, "UTF-16"), "\pM")
}
lang(key:="",str:="",regex:=false,group:="langs",add:="",reset:=false) {
   static custom, custom_main, return, connectors, condition, scripts, signal, langs
   str ? str:=StrUnmark(str)
   if reset||!isObject(return) {
       custom:={}, custom_main={}
       return:=
       (join
          {
             return: ["retornar"]
		  }
	   )
       connectors:=
       (join
          {
             in: ["en"],
			 with: ["=", "con"],
			 to: ["unto", "hacia"]
		  }
	   )
       condition:=
       (join
          {
             if: ["si"],
			 else: ["sino"],
			 while: ["mientras"],
			 until: ["hasta"],
			 do: ["hacer"],
			 use: ["usar"],
			 for: ["para"]
		  }
	   )
       scripts:=
       (join
          {
             js: ["javascript"],
			 vbs: ["vbscript"]
		  }
	   )
       signal:=
       (join
          {
             all: ["todo"],
			 main: ["principal"]
		  }
	   )
	   langs:=
	   (join
		  {
		     escape: [],
			 global: [],
			 set: ["definir"],
			 section: ["seccion"],
			 thread: ["hilo"],
			 press: ["presionar"],
			 import: ["importar"],
			 sleep: ["dormir"],
			 print: ["imprimir","escribir"],
			 msg: ["message","mensaje"],
			 input: ["entrada","leer"],
			 question: ["pregunta"],
			 option: ["opcion"],
			 break: ["romper"],
			 abort: ["abortar"],
			 exit: ["salir"],
			 help: ["ayuda"],
			 read_file: ["leer_archivo"],
			 wait_window: ["esperar_ventana"],
			 wait_console: ["esperar_consola"],
			 start_console: ["iniciar_consola"],
			 read_console: ["leer_consola"],
			 unlock: ["desbloquear"],
			 enable: ["activar"],
			 disable: ["desactivar"],
			 enable_bar: ["activar_barra"],
			 disable_bar: ["desactivar_barra"],
			 add_progress: ["anadir_progreso"],
			 hide: ["ocultar"],
			 show: ["mostrar"],
			 update_key: ["actualizar_key"],
			 web_config: ["config_web"],
			 download: ["descargar"],
			 save: ["guardar"],
			 getsaved: ["obtener_guardado"],
			 push: ["send", "enviar"],
			 install: ["instalar"],
			 delete: ["eliminar"],
			 create: ["crear"],
			 find_device: ["wait_device","esperar_dispositivo"],
			 ensure_shell: ["wait_shell","esperar_shell"],
			 format_data: ["formatear_data"],
			 ensure_tmp: ["asegurar_tmp"],
			 gotolink: ["hacialink"],
			 boot: ["arrancar"],
			 move: ["mover"],
			 update: ["actualizar"],
			 install_recovery_ramdisk: ["instalar_ramdisk_recovery"],
			 update_push: ["update_send", "actualizar_enviar"], 
			 update_ramdisk: ["actualizar_ramdisk"],
			 update_ramdisk_push: ["update_ramdisk_send", "actualizar_ramdisk_enviar"],
			 update_kernel: ["actualizar_kernel"],
			 update_kernel_push: ["update_kernel_send", "actualizar_kernel_enviar"]
		  }
	   )
   }
   if (add&&group) {
      custom[group]:={}, to_return:=0, _pos:=1
      while,(_pos:=RegexMatch(add,"([a-zA-Z_$][a-zA-Z0-9_$]*)(?:[\s=]+(?:\[\s*((?:[^\s\,\]]+[\s\,]*)+)\]))?\s*(?:\,|$)",_with,_pos+StrLen(_with))) {
		if (_with1=group) {
		   if _with2 {
			   custom_main[group]:=[], to_return:=2
			   Loop, parse, _with2, % A_Space . ","""
				  A_LoopField ? custom_main[group].Push(StrUnmark(A_LoopField))
		   }
		} else {
			custom[group][_with1]:=[StrUnmark(_with1)], (!to_return) ? to_return:=1
			if _with2
			   Loop, parse, _with2, % A_Space . ","""
				  A_LoopField ? custom[group][_with1].Push(StrUnmark(A_LoopField))
		}

	  }
	  (!to_return) ? (unexpected:="Invalid Conector definition--->" . add)
	  return to_return
   }
   if (group="custom") {
       if custom.HasKey(key) {
		   for keylang, value in custom[key]
			  for cont, each_value in value
				 if (each_value=str)
				    return keylang
	   }
   } else if key {
       if regex {
	       for cont, each_value in %group%[key]
			   (regex_list ? regex_list.="|" : false), regex_list.=each_value
		   return regex_list
	   }
	   for cont, each_value in %group%[key]
		  if (each_value=str)
			 return 1
   } else {
	   for keylang, value in %group% {
		   if (keylang=str)
		      return keylang
		   for cont, each_value in value
		      if (each_value=str)
			     return keylang
	   }
   }
}
maps(key) {
   static maps
   if !isObject(maps) {
       ; AHK does not support very long expressions, it is necessary to split the object
       maps:=
       (join
          {
		     global: {global: {literal:true}},
			 import: {import: {literal:true}},
			 section: {section: {max:1, literal:true}},
			 thread: {thread: {max:3, literal:true}},
		     print: {print: {max:3}},
		     set: {set: {max:1, literal:true}, with: {support: true}},
		     msg: {msg: {max:2, at:"1,2", atpos:true}, with: {support:true, max:1, at:3}},
			 question: {question: {max:1, at:1, atpos:true}, with: {support:true, max:1, at:2}},
             option: {option: {max:2, at:"1,2", atpos:true}, with: {support:true, expand:true, at:3}},
			 gui: {gui: {literal:true, max:1}},
			 escape: {escape: {literal:true, max:1}},
			 eval: {eval: {literal:true, max:1, ignore_func:true}},
			 for: {for: {literal:true, max:1}, in: {support: true}}
		   }
		)
	   ; Custom definitions
	   maps2:=
       (join
          {  
			 enable: {enable: {literal:true, max:1}},
			 disable: {disable: {literal:true, max:1}},
			 hide: {hide: {literal:true, max:1}},
			 show: {show: {literal:true, max:1}},
			 press: {press: {literal:true, max:1}},
			 update_key: {update_key: {max:1, literal:true, at:1, atpos:true}, with: {support: true, max:1, at:2}},
			 color: {color: {max:1, at:1, atpos:true}, in: {support:true, literal:true, max:1, at:2}},
			 move: {move: {max:1, literal:true, at:1, atpos:true}, to: {support:true, max:1, at:2}},
			 save: {save: {max:1, literal:true, at:1, atpos:true}, with: {support:true, max:1, at:2}, in: {support:true, max:1, at:3}},
			 install: {install: {max:1, at:1, atpos:true}, in: {support:true, literal:true, max:1, at:2}, with: {support:true, max:1, at:3}},
			 download: {download: {max:1, at:1, atpos:true}, in: {support:true, max:1, at:2}, with: {support:true, max:1, at:3}},
			 delete: {delete: {max:1, literal:true}},
			 create: {create: {max:1, literal:true, at:1, atpos:true}, with: {support:true, max:1, at:2}}
		  }
	   )
	   maps3:=
       (join
          {
			 push: {push: {max:1, at:1, atpos:true}, to: {support:true, max:1, at:2}},
			 update: {update: {max:1, at:1, atpos:true}, in: {support:true, literal:true, max:1, at:2}},
			 update_push: {update_push: {max:1, at:1, atpos:true}, in: {support:true, literal:true, max:1, at:2}},
			 update_ramdisk: {update_ramdisk: {max:1, at:1, atpos:true}, in: {support:true, literal:true, max:1, at:2}},
			 update_ramdisk_push: {update_ramdisk_push: {max:1, at:1, atpos:true}, in: {support:true, literal:true, max:1, at:2}},
			 update_kernel: {update_kernel: {max:1, at:1, atpos:true}, in: {support:true, literal:true, max:1, at:2}},
			 update_kernel_push: {update_kernel_push: {max:1, at:1, atpos:true}, in: {support:true, literal:true, max:1, at:2}},
			 install_recovery_ramdisk: {install_recovery_ramdisk: {max:1, literal:true}},
			 find_block: {find_block: {max:1, literal:true}}
		  }
	   )
	   for k, value in maps2
	       maps[k]:=value
	   for k, value in maps3
	       maps[k]:=value
   }
   return maps[key]
}
solve_escape(Byref str,Byref from:="",key:="&") {
   _pos:=1,_extra:=0,_rex:="\[\" . key . "_(\d+)_\" . key . "\]"
   while,(_pos:=RegExMatch(str,_rex,_char,_pos+_extra))
      str:=RegExReplace(str,"s).{" . StrLen(_char) . "}",from[_char1],,1,_pos),_extra:=StrLen(from[_char1])
   return str
}
load_config(configstr:="",local:=false,local_obj:="",from_fd:=0,from_type:="",newmain:=false) {
   global unexpected,secure_user_info,config_tracking
   static Delimiter,Escape,last_label,main_nickname,script_section,FD,SIGNALME,_escape,_thread,_stringtmp,_result,_evaluated,read_line_,ARGS,to_return,regex_expr,regex_main,orig_block,orig_line,script
   (newmain||!isObject(FD)) ? (last_label:="",FD_CURRENT:="",unexpected:="",main_nickname:="",Delimiter:=Chr(34),Escape:=Chr(96),script_section:={},GLOBAL:={},FD:={1:new DObj()},SIGNALME:={exit:1, def:{}},_escape:=["`a","`b","`f","`n","`r`n","`r","`t","`v"],_result:=[],_evaluated:=[],_thread:={},lang(,,,,,true),gui(,,true),config_rc())
   (!regex_expr) ? (regex_expr:="\$\(((?:[^\" . Delimiter . "\(\)]+|([\" . Delimiter . "]).*?\2|\((?:[^\(\)]+|(?R))*\))+)\)", regex_main:="([^;\s]+|;\s*[^;\s]+)\s*((?:\" . Delimiter . "[\s\S]*?\" . Delimiter . "\s*)*)")
   if configstr {
	   local ? (outfd:=FD.MaxIndex()+1, FD[outfd]:=new DObj(local_obj), last_label ? SIGNALME.main:={[outfd]: last_label}) : FD.HasKey(from_fd) ? outfd:=from_fd : outfd:=1
	   if (FD.MaxIndex()>=100) {
	      MsgBox, 262160, Config File, % "Memory limit exceeded for local recursive calls (" . FD.MaxIndex() . ")"
	      SIGNALME.code:=1.1, SIGNALME.exit:=0, FD:=""
	      return 0
	   }
	   StringCaseSense, Off
	   to_return:=0, line:=0, total:=1, _pos:=0
	   while,(_pos:=InStr(configstr,"`n",,_pos+1))
	      total++
   } else {
      return 0
   }
   Loop, parse, configstr, `n,`r 
   {
      line+=1
	  unexpected=
	  FD_CURRENT:=outfd
	  if (SubStr(A_LoopField,1,1)=":"){
	     tag:=SubStr(A_LoopField,2)
		 script ? section ? (script_section[section]:=script,script:="",section:="") : section_txt ? (GLOBAL[section_txt]:=script,script:="",section_txt:="")
		 (_def:=InStr(tag,"->")) ? (_cdef:=SubStr(tag,_def+2),tag:=RTrim(SubStr(tag,1,_def-1)))
	     (SubStr(tag,1,1)=">") ? (tag:=SubStr(tag,2), (tag~="^[a-zA-Z_$][a-zA-Z0-9_$]*$") ? section_txt:=tag : (unexpected:="Invalid variable name--->" . tag)) : ((tag="main") ? section:="" : (tag~="^[a-zA-Z0-9_$]+$") ? section:=tag : (unexpected:="Invalid tag--->" . tag))
		 (_def&&tag&&!unexpected) ? (((_def:=lang(,,,tag,_cdef))&&(SIGNALME.def[tag]:=true)),(_def=2) ? main_nickname:=true) : false
		 if unexpected
		    break
	     else
		    continue
	  } else if (section||section_txt) {
	     script.=A_LoopField . "`r`n"
		 (line=total) ? script ? section ? (script_section[section]:=script,script:="",section:="") : section_txt ? (GLOBAL[section_txt]:=script,script:="",section_txt:="")
		 continue
	  } else if (Floor(SIGNALME.code)=1) {
	     if (SIGNALME.code=1.1||(SIGNALME.code=1&&last_label&&last_label=SIGNALME[outfd].from)||(SIGNALME.code=1.2&&last_label!=SIGNALME.main[outfd]))
		    return SIGNALME.exit
		 else
		    SIGNALME.code:=""
	  }
	  line_indent:=(read_line2:=read_line:=Trim(A_LoopField)) ? RegexMatch(A_LoopField,"^\s+",line_indent) ? StrLen(StrReplace(line_indent,A_Tab,"    ")) : 0 : 0
	  if !(read_line||line=total)
	     continue
	  else if multi_note {
	     (SubStr(read_line,-1)="*#") ? multi_note:=false
		 continue
	  } else if (SubStr(read_line,1,1)="#") {
	     (SubStr(read_line,2,1)="*") ? multi_note:=true
		 continue
	  }
	  (!(newmain||from_type="resolve")) ? (_escape:=["`a","`b","`f","`n","`r`n","`r","`t","`v"],_result:=[],_evaluated:=[]) : newmain:=false
	  main_type:="",main_action:="",main_orig:="",_toresolve:=[]
	  if block_type {
	     if (line_indent>block_indent) {
		    if !block_result {
			   last_label:=back_label
			   continue
			}
			block_capture ? block_capture.="`n"
	        block_capture.=A_LoopField
			if (line!=total)
		       continue
			else
			   last_line_on_block:=true
		 }
		 (last_key:=back_key) ? back_key:="" : last_key:=block_key
		 if block_capture {
		   if (block_key="if"||block_key="else") {
			  to_return:=load_config(block_capture,,,outfd,block_type)
		   } else if (block_key="while") {
			  while,Eval(block_with,FD)[1] {
			     to_return:=load_config(block_capture,,,outfd,block_type)
				 if isObject(SIGNALME.unexpected)||(SIGNALME.code&&Floor(SIGNALME.code)<=3)
					break
			  }
		   } else if (block_key="until") {
			  Loop {
				 to_return:=load_config(block_capture,,,outfd,block_type)
				 if isObject(SIGNALME.unexpected)||(SIGNALME.code&&Floor(SIGNALME.code)<=3)
					break
			  } until,Eval(block_with,FD)[1]
		   } else if (block_key="use") {
		      if (config_tracking=1) {
				  MsgBox, 262145, % "Code Block--->" . last_label . "--->" . block_with1, % block_capture
			      IfMsgBox Cancel
				  {
				     SIGNALME.code:=1.1, SIGNALME.exit:=0
			         return 0
				  }
		      }
			  (block_with="js") ? id:="{16d51579-a30b-4c8b-a276-0ff4dc41e755}" : (block_with="vbs") ? id:="VBScript"
			  try {
				  script:=new ActiveScript(id)
				  script.AddObject("Dino",FD[outfd],true)
				  script.Exec(block_capture)
			   } catch e {
				  from_type:=block_type
				  RegExMatch(e.Message, "s)\s*Line:\s*\K(.*?)(?=\s|\R|$)", line), read_line2:=RegexReplace(LineStr(block_capture,line,1), "\s*(.*)", "$1")
				  if !RegExMatch(e.Message, "s)\s*Description:\s*\K(.*?)(?=\R|$)", unexpected)
					 unexpected:="Invalid syntax\logic"
			   }
		   } else if (block_key="for") {
			  _for:=read_line_, read_line_:=""
			  for key, val in _for.in {
				  FD[outfd][_for.for.1]:=val
				  to_return:=load_config(block_capture,,,outfd,block_type)
				  if isObject(SIGNALME.unexpected)||(SIGNALME.code&&Floor(SIGNALME.code)<=3)
					 break
			  }
			  FD[outfd][_for.for.1]:=""
		   }
		   block_capture:="", last_label:=back_label
		   (unexpected&&!from_type) ? from_type:=block_type
		   if (Floor(SIGNALME.code)=1) {
			  return SIGNALME.exit
		   } else if (Floor(SIGNALME.code)=2) {
		      if lang(,from_type,,"condition") {
			     return to_return
			  } else {
			     SIGNALME.code:=""
		         return SIGNALME.hasobj ? _result[SIGNALME.hasobj] : FD[outfd].HasKey(to_return) ? FD[outfd][to_return] : Eval((to_return~="\[[&``~]_\d+_[&``~]\]") ? solve_escape(solve_escape(solve_escape(to_return, _escape), _result, "``"), _evaluated, "~") : to_return, FD)[1]
			  }
		   } else if (Floor(SIGNALME.code)=3) {
			  (block_key="while"||block_key="until") ? (SIGNALME.code=3) ? SIGNALME.code:=""
			  if SIGNALME.code
				 return SIGNALME.exit
		   }
		 } else if block_result {
		   unexpected:="At least one action was expected for the """ . block_type . """ block"
		 }
         if unexpected||isObject(SIGNALME.unexpected) {
		    last_label:=back_label,read_line2:=orig_block,line:=orig_line
			break
	     } else {
		    block_type:="", block_with:=""
		 }
		 if last_line_on_block {
		    last_line_on_block:=false
		    continue
		 }
	  }
	  if (config_tracking=1)&&(from_type!="resolve")&&read_line {
		 if last_label {
			MsgBox, 262145, % "Block Line--->" . last_label  . "   ( " . line . "/" . total . " )", % read_line
		 } else {
			MsgBox, 262145, % "Main Line   ( " . line . "/" . total . " )", % read_line
		 }
		 IfMsgBox Cancel
		 {
		   SIGNALME.code:=1.1, SIGNALME.exit:=0
		   return 0
		 }
	  }
	  _pos:=1, _extra:=0
	  StringCaseSense, On
	  while,(_pos:=InStr(read_line,Escape,,_pos+_extra)) {
		  if (_end:=Substr(read_line,_pos+1,1)) {
		      switch (_end)
			  {
				case "a": _max:=1
				case "b": _max:=2
				case "f": _max:=3
				case "N": _max:=4
				case "n": _max:=5
				case "r": _max:=6
				case "t": _max:=7
				case "v": _max:=8
				default: _escape.Push(_end), _max:=_escape.MaxIndex()
			  }
			  _max:="[&_" . _max . "_&]",read_line:=RegExReplace(read_line,".{2}",_max,,1,_pos), _extra:=StrLen(_max)
		  } else {
		     break
		  }
	  }
	  StringCaseSense, Off
	  _pos:=1, _extra:=0
	  while,(_pos:=RegExMatch(read_line,regex_expr,_char,_pos+_extra))
		 _result.Push(_char), _max:=_result.MaxIndex(), _toresolve.Push(_max), _max:="[``_" . _max . "_``]", read_line:=RegExReplace(read_line,".{" . StrLen(_char) . "}",_max,,1,_pos), _extra:=StrLen(_max)
	  _pos:=1, _extra:=0
	  while,(_pos:=InStr(read_line,"%",,_pos+_extra))
	  {
		  if (_end:=InStr(read_line,"%",,_pos+1)) {
		      _eval:=Substr(read_line,_pos+1,(_end-_pos)-1)
		      InStr(_eval, "[&_") ? _eval:=solve_escape(_eval,_escape)
			  _expr:=1,_count:="",_hasexpr:=false
			  while,(_expr:=RegexMatch(_eval,"\[``_(\d+)_``\]",_count,_expr+StrLen(_count))) {
				 _hasexpr:=true
				 for count, value in _toresolve {
					 if (value=_count1) {
						_toresolve.RemoveAt(count)
						break
					 }
				 }
			  }
			  _hasexpr ? _eval:=solve_escape(_eval,_result,"``")
			  _eval:=Eval(_eval, FD)[1]
			  if isObject(SIGNALME.unexpected)
				 break 2
			  if (_eval="")
			     _eval_rpl:=""
			  else if _eval is Number
			     _eval_rpl:=_eval
			  else
			     _evaluated.Push(_eval), _eval_rpl:="[~_" . _evaluated.MaxIndex() . "_~]"
			  _eval:=""
			  read_line:=RegExReplace(read_line,".{" . (_end-_pos)+1 . "}",_eval_rpl,,1,_pos), _extra:=StrLen(_eval_rpl)
		  } else {
			 break
		  }
	  }
	  RegExMatch(read_line, "^(\S+)\s*", condition)
	  if (condition1&&block_key:=lang(,condition1,,"condition")) {
		 block_capture:="", block_indent:=line_indent, block_type:=condition1, block_with:=SubStr(read_line,StrLen(condition)+1), orig_block:=read_line2, orig_line:=line
	     back_label:=last_label
		 if (block_key="else") {
			(last_key!="else") ? block_result ? else_used:=true : else_used:=false
			if (block_result="") {
			   unexpected:="Expected a conditional block prior to """ . block_type . """"
			   break
			} else if (!else_used&&!block_result) {
			   (block_with&&RegExMatch(block_with, "^(\S+)\s*", condition)&&(block_key:=lang(,condition1,,"condition"))) ? (back_key:="else", block_type:=condition1, block_with:=SubStr(block_with,StrLen(condition)+1)) : block_with:=1
			} else {
			   block_with:=0
			}
		 }
		 (block_with~="\[[&``~]_\d+_[&``~]\]") ? block_with:=solve_escape(solve_escape(solve_escape(block_with, _escape), _result, "``"), _evaluated, "~")
		 last_label:=block_type
		 if (block_key="use") {
			 if RegExMatch(block_with,"(\S+)",block_with) {
				if (block_with:=lang(,block_with,,"scripts")) {
				   block_result:=1
				   if secure_user_info&&!question("ActiveScript", """" . block_with1 . """ code is going to be executed, do you want to allow it?`n`nNOTE: This code will not have a security check, be careful")
					  block_result:=0
				} else {
				   unexpected:="Unrecognized code block type--->" . block_with1
				}
			 } else {
				unexpected:="Expected code block type"
			 }
		 } else {
			 (block_key="for") ? (block_result:=1, with_partial:=block_key, block_with:="") : Eval(block_with,FD)[1] ? block_result:=1 : block_result:=0
			 (Floor(SIGNALME.code)=3&&(block_key="while"||block_key="until")) ? SIGNALME.code:=""
			 (block_key="until") ? block_result ? block_result:=0 : block_result:=1
		 }
		 if unexpected {
			last_label:=back_label
			break
		 } else if !with_partial {
			continue
		 }
	  }
	  SIGNALME.hasobj ? SIGNALME.hasobj:=false
	  if _toresolve.MaxIndex() {
		_resulttmp:=_result,_evaluatedtmp:=_evaluated,_escapetmp:=_escape,_result:=[],_evaluated:=[]
		for count, value in _toresolve {
			_resulttmp[value]:=load_config(Substr(_resulttmp[value],3,-1),,,outfd,"resolve")
			(count=1) ? isObject(_resulttmp[value]) ? SIGNALME.hasobj:=value
			if unexpected
				break 2
		}
		_result:=_resulttmp, _evaluated:=_evaluatedtmp, _escape:=_escapetmp, _resulttmp:="", _evaluatedtmp:="", _escapetmp:=""
	  }
	  _pos:=1, _extra:=0, _stringtmp:=[]
      while,(_pos:=InStr(read_line,"""",,_pos+_extra))
      {
		  if (_end:=InStr(read_line,"""",,_pos+1)) {
			  _string:=Substr(read_line,_pos+1,(_end-_pos)-1)
		      if (_string!="") {
			     (_string~="\[[&``~]_\d+_[&``~]\]") ? _string:=solve_escape(solve_escape(solve_escape(_string, _escape), _result, "``"), _evaluated, "~")
			     _stringtmp.Push(_string), _string:="", _string_rpl:="""[&_" . _stringtmp.MaxIndex() . "_&]"""
			     read_line:=RegExReplace(read_line,".{" . (_end-_pos)+1 . "}",_string_rpl,,1,_pos), _extra:=StrLen(_string_rpl)
			  } else {
			     _extra:=2
			  }
		  } else {
			 unexpected:="A closure was expected--->"""
			 break 2
		  }
      }
	  _escape:=_stringtmp, _stringtmp:=""
	  if (condition1&&lang(,condition1,,"return")) {
	     _return:=SubStr(read_line,StrLen(condition)+1)
		 if (from_type&&lang(,from_type,,"condition")&&SIGNALME.code:=2)
		    return _return
		 else
		    return SIGNALME.hasobj ? _result[SIGNALME.hasobj] : FD[outfd].HasKey(_return) ? FD[outfd][_return] : Eval((_return~="\[[&``~]_\d+_[&``~]\]") ? solve_escape(solve_escape(solve_escape(_return, _escape), _result, "``"), _evaluated, "~") : _return, FD)[1]
	  }
	  _pos:=1, _char:="", _lastoption:="", just_one:=false, read_line_:={}
	  while,(_pos:=RegExMatch(read_line,regex_main,_char,_pos+StrLen(_char)))
	  {
		 if (_chr:=SubStr(_char1,1,1))&&(_chr="#"||_chr=";")
			break
		 else if (just_one&&unexpected:="Only one action expected")
		    break 2
		 option:=InStr(_char1,"[~_") ? solve_escape(_char1,_evaluated,"~") : _char1
		 if (option!="") {
			back_opt:=option, overwrite:=true, _expand:="", _literal:="", _number:="", _var:="", _var1:="", _var2:="", _var3:=""
			if (_pos=1) {
			    if with_partial {
                    main_action:=with_partial, option:=main_action, maps:=maps(main_action)
			    } else if (SubStr(option,1,3)="[``_")||((_chr:=SubStr(option,-1))&&(_chr="++"||_chr="--")) {
				    just_one:=true, _chr ? (_var:=SubStr(option,1,-2)) ? FD[outfd].HasKey(_var) ? (((_chr="++") ? FD[outfd][_var]++ : FD[outfd][_var]--),to_return:=FD[outfd][_var])
					continue
				} else {
				    (main_nickname&&_try:=lang(,option,,"custom_main")) ? option:=_try
					script_section[option] ? main_type:="section" : isFunc(option) ? main_type:="function" : (main_action:=lang(,option))
					main_type ? main_action:=option : isFunc(main_action) ? main_type:="function" : main_type:="lang"
					if main_action {
					   main_orig:=option, option:=main_action, maps:=maps(main_action), SIGNALME.def.HasKey(main_action) ? custom_option:=true : custom_option:=false, maps[main_action].ignore_func ? main_type:="lang"
					} else {
					   unexpected:=(option~="\[[&``]_\d+_[&``]\]") ? "Only %expressions% are allowed for the main action and connectors" : "Invalid start of action--->" . option
					   break 2
					}
				}
			}
			if (_pos=1)||(_expand:=(SubStr(option,0)="*"))||(_literal:=InStr(option,"[``_") ? "$" : InStr(option,"[&_") ? "&" : false)||(_number:=(option~="^-?\d+(\.\d+)?$"))||(custom_option&&option:=lang(main_action,option,,"custom"))||(option:=lang(,back_opt,,"connectors"))||always_literal||((_var:=FD[outfd].HasKey(back_opt))||RegexMatch(back_opt, "^([a-zA-Z_$][a-zA-Z0-9_$]*?)(?=(\[((?:[^\[\]]++|(?2))*)\])$)", _var)) {
				if (_expand||_literal||_number||_var) {
				   _var3 ? _var3:=Eval(_var3,FD)[1] : _var:=back_opt
				   _literal ? (inkey:=SubStr(_var,4,-3))
				   if (option:=_lastoption) {
				      if _expand {
					      _var:=SubStr(_var,1,-1)
					      if FD[outfd].HasKey(_var)&&isObject(FD[outfd][_var])
						      for cont, value in FD[outfd][_var]
							      read_line_[option].Push(value)
					  } else {
					     _literal ? read_line_[option].Push((_literal="$"&&_result.HasKey(inkey)) ? _result[inkey] : _escape.HasKey(inkey) ? _escape[inkey] : "") : read_line_[option].Push(_number ? _var : _var3 ? FD[outfd][_var][_var3] : FD[outfd][_var])
					  }
					  overwrite:=false
				   } else {
					  unexpected:="A connector/action was expected before the "
					  unexpected.=_literal ? "expression" : _number ? "number" : "variable"
					  unexpected.="--->" . _var
					  break 2
				   }
				}
				(always_literal&&!option) ? (option:=always_literal, read_line_[option].Push(back_opt), overwrite:=false)
				maps[option].concat ? (option:=maps[option].concat, overwrite:=false)
				maps[option].literal ? always_literal:=option : always_literal:=false
				if !(option=main_action||main_type="section") && !maps[option].support {
				   unexpected:="""" . main_orig . """ doesn't support the connector--->" . back_opt
				   break 2
			    }
				(overwrite||!isObject(read_line_[option])) ? (read_line_[option]:=[],_lastoption:=option)
				parameter:=StrSplit(_char2,Delimiter)
				parameter[1] ? ARGS_N:=1 : ARGS_N:=0
				parameter_end:=parameter.MaxIndex()
				parameter[parameter_end] ? parameter_end:=false
				for count, value in parameter {
				   (Mod(ARGS_N, 2)&&count!=parameter_end) ? read_line_[option].Push(solve_escape(value, _escape))
				   ARGS_N++
				}
				parameter:=""
				if maps[option].max&&(read_line_[option].MaxIndex()>maps[option].max) {
					unexpected:=option . "---> Only supports " . maps[option].max . " parameters"
					break 2
				}
			} else {
			   unexpected:="Unrecognized connector--->" . back_opt
			   break 2
			}
		 } else {
			unexpected:="Invalid resolution"
			break 2
		 }
	  }
	 back_label:=last_label
	 if with_partial {
		switch (with_partial) {
			case "for":
                if !(read_line_[with_partial].1 ~= "^[a-zA-Z_$][a-zA-Z0-9_$]*$") {
					unexpected:="Invalid variable name--->" . read_line_[with_partial].1
					break
				}
		}
		with_partial:=""
		continue
	 } else if (main_type="section") {
		last_label:=main_action
		to_return:=load_config(script_section[main_action],true,read_line_)
		(FD_CURRENT>1) ? FD.Pop()
		FD_CURRENT:=outfd, last_label:=back_label
		if isObject(SIGNALME.unexpected)
		   break
	 } else if (main_type="function") {
		if maps[main_action].atpos {
		  ARGS:=[]
		  for key in read_line_ {
			 if maps[key].at {
				Loop, parse, % maps[key].at, `,
				{
				   if maps[key].expand {
					  for count, value in read_line_[key]
						  ARGS[A_LoopField+count-1]:=value
				   } else {
					  ARGS[A_LoopField]:=read_line_[key][A_Index]
				   }
				}
			 }
		  }
		  read_line_:={}, read_line_[main_action]:=ARGS, ARGS:=""
		}
		to_return:=(skip_functions&&main_action~=skip_functions) ? "" : %main_action%(read_line_[main_action]*)
		if unexpected
		    break	
	 } else {
		switch (main_action) {
		   case "global":
			   for count, value in read_line_.global {
				  if (value ~= "^[a-zA-Z_$][a-zA-Z0-9_$]*$") {
					 FD[outfd].global(value)
				  } else {
					 unexpected:="Invalid variable name--->" . value
					 break 2
				  }
			   }
		   case "import":
			   for count, value in read_line_.import {
				  if InStr(FileExist(value), "A") {
					 load_config(read_file(value),,,outfd,"import:" . value)
				     if unexpected||isObject(SIGNALME.unexpected)
		                break 2
				  } else {
					 unexpected:="Cant find--->" . value
					 break 2
				  }
			   }
		   case "escape":
		        if (StrLen(read_line_.escape.1)=1)
				   Escape:=read_line_.escape.1
				else {
				   unexpected:="Invalid escape character-->" . read_line_.escape.1
				   break
				}
		   case "break":
				SIGNALME.code:=3
				return 1
		   case "abort":
				read_line_.abort.MaxIndex() ? print(read_line_.abort*)
				load_config(,,,,,true)
				SIGNALME.code:=1.1, SIGNALME.exit:=0
				return 0
		   case "exit":
				last_label ? SIGNALME[outfd].from:=last_label
				if lang("all",read_line_.exit.1,,"signal") {
				   SIGNALME.code:=1.1
				} else if lang("main",read_line_.exit.1,,"signal") {
				   SIGNALME.code:=1.2
				} else {
				   SIGNALME.code:=1
				}
				return 1
		   case "set":
			   if (read_line_.set.1 ~= "^[a-zA-Z_$][a-zA-Z0-9_$]*$") {
				   try {
					  (read_line_.with.MaxIndex()>1) ? FD[outfd][read_line_.set.1]:=read_line_.with : FD[outfd][read_line_.set.1]:=read_line_.with.1
				   } catch {
					  unexpected:="Could not define var--->" . read_line_.set.1
					  break
				   }
			   } else if RegexMatch(read_line_.set.1, "^([a-zA-Z_$][a-zA-Z0-9_$]*?)(?=(\[((?:[^\[\]]++|(?2))*)\])$)", _var) {
			       _var3:=Eval(_var3,FD)[1], (!isObject(FD[outfd][_var])) ? FD[outfd][_var]:={}
				   try {
					  (read_line_.with.MaxIndex()>1) ? FD[outfd][_var][_var3]:=read_line_.with : FD[outfd][_var][_var3]:=read_line_.with.1
				   } catch {
					  unexpected:="Could not define var--->" . read_line_.set.1
					  break
				   }
			   } else {
				   unexpected:="Invalid variable name--->" . read_line_.set.1
				   break
			   }
		   case "section":   
			   if script_section.HasKey(read_line_.section.1) {
			      last_label:=read_line_.section.1
				  to_return:=load_config(script_section[last_label],,,outfd)
				  last_label:=back_label
				  if isObject(SIGNALME.unexpected)
		             break
			   }
		   case "thread":
		        if script_section.HasKey(read_line_.thread.1) {
				   if (read_line_.thread.2~="i)^(-?\d+)|on|off|delete$"||read_line_.thread.2:=-1)
					   _thread.HasKey(read_line_.thread.1) ? _thread[read_line_.thread.1].Parse(read_line_.thread.2) : _thread[read_line_.thread.1]:=new Thread("load_config",read_line_.thread.2,script_section[read_line_.thread.1],,,outfd)
                   if isObject(SIGNALME.unexpected)
		              break
				}
		   case "eval":   
				to_return:=Eval(read_line_.eval.1,FD)
				if isObject(SIGNALME.unexpected)
		           break
		}	   
	 }
     read_line_:=""
	 (_chr=";") ? to_return:=load_config(Substr(read_line,_pos+1),,,outfd,"resolve")
   }
   if unexpected||isObject(SIGNALME.unexpected) {
     read_line_:=""
	 if block_type {
		 if block_with
			main_orig:=block_type . "--->" . (block_with1 ? block_with1 : block_with)
		 else
			main_orig:=block_type
	 }
	 (!last_label||from_type="resolve"||with_partial) ? show_error:=true
     if !isObject(SIGNALME.unexpected) {
	    if (from_type="resolve")
		   SIGNALME.unexpected:={unexpected: unexpected, last_label: "", to_show: last_label ? "Error in expression from--->" . last_label : "Line: " . line . "--in---> Expression", main_orig: main_orig, read_line2: solve_escape(solve_escape(solve_escape(read_line2, _escape), _result, "``"), _evaluated, "~")}
		else if (from_type&&InStr(from_type,"import:"))
		   SIGNALME.unexpected:={unexpected: unexpected, to_show: "Error in line: " . line . "`nFile: " RegExReplace(SubStr(from_type,InStr(from_type,":")), ".*\\([^\\]+)$", "$1"), main_orig: main_orig, read_line2: read_line2, show_error: true}
		else if lang(,from_type,,"condition")
		   SIGNALME.unexpected:={unexpected: unexpected, line: line . "--from---> " . from_type, main_orig: main_orig, read_line2: read_line2, show_error: true}
		else
	       SIGNALME.unexpected:={unexpected: unexpected, last_label: last_label, line: line, main_orig: main_orig, read_line2: read_line2, show_error: true}
	 } else if last_label && !SIGNALME.unexpected.last_label {
	    SIGNALME.unexpected.last_label:=last_label
     }
	 if show_error {
		 for key, value in SIGNALME.unexpected
		    %key%:=value
		 read_line2 ? unexpected.="`n`n---> " . read_line2
		 to_show:=to_show ? to_show : last_label ? "Error in tag: " . last_label . "`nLine: " . line : "Error in line: " . line
		 main_orig ? to_show.="`nAction: " . main_orig
		 to_show.="`nReason: " . unexpected
		 load_config(,,,,,true)
		 SIGNALME.code:=1.1, SIGNALME.exit:=0
		 MsgBox, 262160, Config Exception, % to_show
	 }
	 return 0
   } else {
     return to_return
   }
}
RuntimeError(error) {
   MsgBox, 262160, Runtime Exception, % "Internal error in -> [" . A_ScriptName . "]`n`nFile: " . RegExReplace(error.file, ".*\\([^\\]+)$", "$1") . "`nLine: " . error.line . "`nReason: " .  error.message . "`n`n---> " . error.what
   ExitApp
}