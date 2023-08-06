;=======================================================================================
;
; Function:			Eval
; Description:		Evaluate Expressions in Strings.
; Return value:		An array (object) with the result of each expression.
;
; Relative Author:  BlassGO (Optimized with rebuild of Eval for DinoCode purposes)
; Credits:          Original version by Pulover [Rodolfo U. Batista]
; Credits:			ExprEval() by Uberi
;
;=======================================================================================
;
; Parameters:
;
;	$x:				The input string to be evaluated. You can enter multiple expressions
;						separated by commas (inside the string).
;	_CustomVars:	An optional Associative Array object containing variables names
;					  as keys and values to replace them. (For DinoCode there are two levels in the object, one that corresponds to the FD and its internal object with the variables as keys.)
;					For example, setting it to {A_Index: A_Index} inside a loop will replace
;						occurrences of A_Index with the correct value for the iteration.
;	_Init:			Used internally for the recursive calls. If TRUE it resets the static
;						object _Objects, which holds objects references to be restored.
;
;
;=======================================================================================
SetBatchLines -1

Eval($x, Byref _CustomVars := "", _Init := true)
{
	Static _Objects, $Quote:=Chr(2), regex_expr
	(!regex_expr) ? regex_expr:="\$\(((?:[^\" . Chr(34) . "\(\)]+|([\" . Chr(34) . "]).*?\2|\((?:[^\(\)]+|(?R))*\))+)\)"
	
	_Elements := {}
	If (_Init)
		_Objects := {}

	; Resolve DinoCode references
	; ExprEval() cannot parse Unicode strings, so the "real" strings are "hidden" from ExprCompile() and restored later
    while RegExMatch($x,regex_expr,_char) {
	  $y := load_config(_char1,,, FD_CURRENT, "resolve")
	  if unexpected
	     return 0
	  if IsObject($y)
	     ObjName:="$" . A_Index . "$", _Objects[ObjName]:=$y.Clone(), $y := """<~#" . ObjName . "#~>"""
	  else if $y is not Number
	     HidString := "_&String" A_Index "&_", _Elements[HidString] := StrReplace($y, """", $Quote), $y := """" HidString """"
	  $x := StrReplace($x, _char, $y,, 1)
    }
		
	; Hiding strings
	_pos:=1, _extra := 0
    while (_pos := InStr($x, """",, _pos+_extra))
    {
	  if (_end := InStr($x, """",, _pos+1)) {
	      _Elements["_&String" _Elements.Count()+1 "&_"] := Substr($x, _pos+1, (_end-_pos)-1), $x := RegExReplace($x,"s).{" (_end-_pos)-1 "}", "_&String" _Elements.Count() "&_",,1,_pos+1), _extra := StrLen("_&String" _Elements.Count() "&_")+2
	  } else {
		 unexpected := "A closure was expected--->"""
		 return 0
	  }
    }
	
	; Hiding Brackets
	While (RegExMatch($x, "\[([^\[\]]++|(?R))*\]", _Bracket))
		_Elements["_&Bracket" A_Index "&_"] := _Bracket
	,	$x := StrReplace($x, _Bracket, "_&Bracket" A_Index "&_",, 1)
	
	; Hiding Braces
	While (RegExMatch($x, "\{[^\{\}]++\}", _Brace))
		_Elements["_&Brace" A_Index "&_"] := _Brace
	,	$x := StrReplace($x, _Brace, "_&Brace" A_Index "&_",, 1)
	
	; Hiding Parenthesis
	While (RegExMatch($x, "\(([^()]++|(?R))*\)", _Parent))
		_Elements["_&Parent" A_Index "&_"] := _Parent
	,	$x := StrReplace($x, _Parent, "_&Parent" A_Index "&_",, 1)
	
	; Split multiple expressions
	$z := StrSplit($x, ",", " `t")
	
	For $i, $v in $z
	{
	    ; Check for Object calls
		_Pos := 1
		While (RegExMatch($z[$i], "([\w%]+)(\.|_&Bracket|_&Parent\d+&_)[\w\.&%]+(.*)", _Match, _Pos))
		{
			AssignParse(_Match, VarName, Oper, VarValue)
			If (Oper != "")
			{
				VarValue := StrJoin(Eval(RestoreElements(VarValue, _Elements), _CustomVars, false))
				If (!IsObject(VarValue))
					VarValue := RegExReplace(VarValue, """{2,2}", """")
			}
			Else
				_Match := StrReplace(_Match, _Match3), VarName := _Match
			VarName := RestoreElements(VarName, _Elements)
			
			If _Match1 is Number
			{
				_Pos += StrLen(_Match1)
				continue
			}
			$y := ParseObjects(VarName, _CustomVars, Oper, VarValue), ObjName := RegExReplace(_Match, "\W", "_")
	        If (IsObject($y))
				_Objects[ObjName] := $y
			Else If $y is not Number
			{
				HidString := "_&String" _Elements.Count()+1 "&_"
			,	_Elements[HidString] := StrReplace($y, """", $Quote)
			,	$y := """" HidString """"
			}
			$z[$i] := StrReplace($z[$i], _Match, IsObject($y) ? """<~#" ObjName "#~>""" : $y,, 1)
		}
		
		; Assign Arrays
		While (RegExMatch($z[$i], "_&Bracket\d+&_", $pd))
		{
			$z[$i] := StrReplace($z[$i], $pd, _Elements[$pd],, 1)
		,	RegExMatch($z[$i], "\[(.*)\]", _Match)
		,	ObjName := RegExReplace(_Match, "\W", "_"), _Objects[ObjName] := Eval(RestoreElements(_Match1, _Elements), _CustomVars, false), $z[$i] := StrReplace($z[$i], _Match, """<~#" ObjName "#~>""")
		}
		
		; Restore and evaluate any remaining parenthesis
		; Considering mathematical/logical parents
		_pos := 1, _extra := 0
		While _pos := RegExMatch($z[$i], "_&Parent\d+&_", $pd, _pos + _extra)
		{
		    if (_Elements[$pd] ~= "^\([\d\.,\s:\+-=*/&|^><\?]+\)$") {
			   RepString := RestoreElements($pd, _Elements)
			} else {
					_oMatch := StrSplit(_Elements[$pd], ",", " `t()")
				,	_Match := RegExReplace(_Elements[$pd], "\((.*)\)", "$1")
				,	_Match := RestoreElements(_Match, _Elements)
				,	EvalResult := Eval(_Match, _CustomVars, false)
				,	RepString := "("
					For _i, _v in EvalResult
					{
						ObjName := RegExReplace($pd . _i, "\W", "_")
						If (IsObject(_v))
							_Objects[ObjName] := _v
						Else If _v is not Number
						{
							If (_oMatch[_i] != "")
							{
								HidString := "_&String" _Elements.Count()+1 "&_"
							,	_Elements[HidString] := StrReplace(_v, """", $Quote)
							,	_v := """" HidString """"
							}
						}
						RepString .= (IsObject(_v) ? """<~#" ObjName "#~>""" : _v) ", "
					}
					RepString := RTrim(RepString, ", ") ")"
			}
			$z[$i] := StrReplace($z[$i], $pd, RepString,, 1), _extra := StrLen(RepString)
		}
				
		; Check whether the whole string is an object
		if ($y := $z[$i]) {
			Try
			{
				If _CustomVars[FD_CURRENT].HasKey($y)
				{
					If IsObject(_CustomVars[FD_CURRENT][$y])
						ObjName := RegExReplace($y, "\W", "_"), _Objects[ObjName] := _CustomVars[FD_CURRENT][$y].Clone(), $z[$i] := """<~#" ObjName "#~>"""
				}
				Else If IsObject(%$y%)
					ObjName := RegExReplace($y, "\W", "_"), _Objects[ObjName] := %$y%.Clone(), $z[$i] := """<~#" ObjName "#~>"""
			}
		}
		
		; Check for {} object assignment
		If (RegExMatch($z[$i], "\{\s*\}", _Match))
			$y := Object(), ObjName := "_emptyObj", _Objects[ObjName] := $y, $z[$i] := StrReplace($z[$i], _Match, """<~#" ObjName "#~>""")

		; Check for Functions
		; but ignore some insecure functions
		While (RegExMatch($z[$i], "s)([\w%]+)\((.*?)\)", _Match))
		{
			$y := (skip_functions&&_Match1~=skip_functions) ? "" : %_Match1%(Eval(RestoreElements(_Match2, _Elements), _CustomVars)*)
		,	ObjName := RegExReplace(_Match, "\W", "_")
			If (IsObject($y))
				_Objects[ObjName] := $y
			Else If $y is not Number
			{
				HidString := "_&String" _Elements.Count()+1 "&_"
			,	_Elements[HidString] := StrReplace($y, """", $Quote)
			,	$y := """" HidString """"
			}
			$z[$i] := StrReplace($z[$i], _Match, IsObject($y) ? """<~#" ObjName "#~>""" : $y,, 1)
		}

		; Dereference variables in percent signs
		While (RegExMatch($z[$i], "U)%(\S+)%", _Match))
			$z[$i] := StrReplace($z[$i], _Match, Eval(_Match1, _CustomVars, false)[1])

		; Add concatenate operator after strings where necessary
		While (RegExMatch($z[$i], "(""_&String\d+&_""\s+)([^\d\.,\s:\+-=*/&|^><\?])"))
			$z[$i] := RegExReplace($z[$i], "(""_&String\d+&_""\s+)([^\d\.,\s:\+-=*/&|^><\?])", "$1. $2")

		; Evaluate parsed expression with ExprEval()
		ExprInit()
	,	CompiledExpression := ExprCompile($z[$i])
	,	$Result := ExprEval(CompiledExpression, _CustomVars, _Objects, _Elements)
	,	$Result := StrSplit($Result, Chr(1))
		
		; Restore object references
		For _i, _v in $Result
		{
			If (RegExMatch(_v, "^<~#(.*)#~>$", $pd))
				$Result[_i] := _Objects[$pd1]
		}
		$z[$i] := StrJoin($Result,, false)
	}
	
	; If returning to the original call, remove missing expressions from the array
	If (_Init)
	{
		$x := StrSplit($x, ",", " `t")
		For _i, _v in $x
		{
			If (_v = "")
				$z.Delete(_i)
		}
	}
    
	return $z
}

ParseObjects(v_String, Byref _CustomVars := "", o_Oper :=  "", o_Value := "")
{
	Static _needle := "([\w%]+\.?|\(([^()]++|(?R))*\)\.?|\[([^\[\]]++|(?R))*\]\.?)"
	
	l_Matches := [], _Pos := 1
	While (_Pos := RegExMatch(v_String, _needle, l_Found, _Pos))
		l_Matches.Push(RegExMatch(RTrim(l_Found, "."), "^%(\S+)%$", $pd) ? %$pd1% : RTrim(l_Found, "."))
	,	_Pos += StrLen(l_Found)
	v_Obj := l_Matches[1]
	if (skip_functions&&v_Obj~=skip_functions)||(skip_vars&&v_Obj~=skip_vars)
	   return 
	If (_CustomVars[FD_CURRENT].HasKey(v_Obj))
		_ArrayObject := _CustomVars[FD_CURRENT][v_Obj]
	Else
		Try _ArrayObject := %v_Obj%
	For $i, $v in l_Matches
	{
		If (RegExMatch($v, "^\((.*)\)$"))
			continue
		If (RegExMatch($v, "^\[(.*)\]$", l_Found))
			_Key := Eval(l_Found1, _CustomVars, false)
		Else
			_Key := [$v]
		$n := l_Matches[$i + 1]
		If (RegExMatch($n, "^\((.*)\)$", l_Found))
		{
			_Key := _Key[1]
		,	_Params := Eval(l_Found1, _CustomVars, false)
			
			Try
			{
				If ($i = 1)
					_ArrayObject := %_Key%(_Params*)
				Else
					_ArrayObject := _ArrayObject[_Key](_Params*)
			}
			Catch e
			{
				If (InStr(e.Message, "0x800A03EC"))
				{
					; Workaround for strange bug in some Excel methods
					For _i, _v in _Params
						_Params[_i] := " " _v
				
					If ($i = 1)
						_ArrayObject := %_Key%(_Params*)
					Else
						_ArrayObject := _ArrayObject[_Key](_Params*)
				}
				Else
					Throw e
			}
		}
		Else If (($i = l_Matches.Length()) && (o_Value != ""))
		{
			Try
			{
				If (o_Oper = ":=")
					_ArrayObject := _ArrayObject[_Key*] := o_Value ? o_Value : false
				Else If (o_Oper = "+=")
					_ArrayObject := _ArrayObject[_Key*] += o_Value ? o_Value : false
				Else If (o_Oper = "-=")
					_ArrayObject := _ArrayObject[_Key*] -= o_Value ? o_Value : false
				Else If (o_Oper = "*=")
					_ArrayObject := _ArrayObject[_Key*] *= o_Value ? o_Value : false
				Else If (o_Oper = "/=")
					_ArrayObject := _ArrayObject[_Key*] /= o_Value ? o_Value : false
				Else If (o_Oper = "//=")
					_ArrayObject := _ArrayObject[_Key*] //= o_Value ? o_Value : false
				Else If (o_Oper = ".=")
					_ArrayObject := _ArrayObject[_Key*] .= o_Value ? o_Value : false
				Else If (o_Oper = "|=")
					_ArrayObject := _ArrayObject[_Key*] |= o_Value ? o_Value : false
				Else If (o_Oper = "&=")
					_ArrayObject := _ArrayObject[_Key*] &= o_Value ? o_Value : false
				Else If (o_Oper = "^=")
					_ArrayObject := _ArrayObject[_Key*] ^= o_Value ? o_Value : false
				Else If (o_Oper = ">>=")
					_ArrayObject := _ArrayObject[_Key*] >>= o_Value ? o_Value : false
				Else If (o_Oper = "<<=")
					_ArrayObject := _ArrayObject[_Key*] <<= o_Value ? o_Value : false
			}
		}
		Else If ($i > 1)
			_ArrayObject := _ArrayObject[_Key*]
	}
	return _ArrayObject
}

RestoreElements(_String, Byref _Elements)
{
    _pos := 1, _extra := 0
	While _pos := RegExMatch(_String, "_&\w+&_", $pd, _pos+_extra)
        _String := StrReplace(_String, $pd, _Elements[$pd]), _extra := StrLen(_Elements[$pd])
	return _String
}

AssignParse(String, ByRef VarName, ByRef Oper, ByRef VarValue)
{
	RegExMatch(String, "(.*?)(:=|\+=|-=|\*=|/=|//=|\.=|\|=|&=|\^=|>>=|<<=)(?=([^""]*""[^""]*"")*[^""]*$)(.*)", Out)
,	VarName := Trim(Out1), Oper := Out2, VarValue := Trim(Out4)
}

StrJoin(Byref InputArray, JChr := "", Quote := false, Init := true, Unquote := false)
{
	static $Quote := Chr(2)
	For i, v in InputArray
	{
		If (IsObject(v))
			return v
		If v is not Number
		{
			If (!Init)
				v := RegExReplace(v, """{1,2}", """""")
			If (Quote)
				v := """" v """"
			If (Unquote)
				While (RegExMatch(v, """{2}"))
					v := RegExReplace(v, """{2}", """")
			v := StrReplace(v, $Quote, """")
		}
		JoinedStr .= v . JChr
	}
	If (JChr != "")
		JoinedStr := SubStr(JoinedStr, 1, -(StrLen(JChr)))
	return JoinedStr
}

;##################################################
; Author: Uberi
; Modified by: Pulover
; http://autohotkey.com/board/topic/64167-expreval-evaluate-expressions/
;##################################################
ExprInit()
{
	global
	Exprot:="`n:= 0 R 2`n+= 0 R 2`n-= 0 R 2`n*= 0 R 2`n/= 0 R 2`n//= 0 R 2`n.= 0 R 2`n|= 0 R 2`n&= 0 R 2`n^= 0 R 2`n>>= 0 R 2`n<<= 0 R 2`n|| 3 L 2`n&& 4 L 2`n\! 5 R 1`n= 6 L 2`n== 6 L 2`n<> 6 L 2`n~= 6 L 2`n!= 6 L 2`n> 7 L 2`n< 7 L 2`n>= 7 L 2`n<= 7 L 2`n\. 8 L 2`n& 9 L 2`n^ 9 L 2`n| 9 L 2`n<< 10 L 2`n>> 10 L 2`n+ 11 L 2`n- 11 L 2`n* 12 L 2`n/ 12 L 2`n// 12 L 2`n\- 13 R 1`n! 13 R 1`n~ 13 R 1`n\& 13 R 1`n\* 13 R 1`n** 14 R 2`n\++ 15 R 1`n\-- 15 R 1`n++ 15 L 1`n-- 15 L 1`n. 16 L 2`n`% 17 R 1`n",Exprol:=SubStr(RegExReplace(Exprot,"iS) \d+ [LR] \d+\n","`n"),2,-1)
	Sort,Exprol,FExprols
}

ExprCompile(Byref e)
{
	e:=Exprt(e)
	Loop,Parse,e,% Chr(1)
	{
		lf:=A_LoopField,tt:=SubStr(lf,1,1),to:=SubStr(lf,2)
		If tt=f
		Exprp1(s,lf)
		Else If lf=,
		{
			While,s<>""&&Exprp3(s)<>"("
			Exprp1(ou,Exprp2(s))
		}
		Else If tt=o
		{
			While,SubStr(so:=Exprp3(s),1,1)="o"
			{
				ta:=Expras(to),tp:=Exprpr(to),sop:=Exprpr(SubStr(so,2))
				If ((ta="L"&&tp>sop)||(ta="R"&&tp>=sop))
				Break
				Exprp1(ou,Exprp2(s))
			}
			Exprp1(s,lf)
		}
		Else If lf=(
		Exprp1(s,"(")
		Else If lf=)
		{
			While,Exprp3(s)<>"("
			{
				If s=
				Return
				Exprp1(ou,Exprp2(s))
			}
			Exprp2(s)
			If (SubStr(Exprp3(s),1,1)="f")
			Exprp1(ou,Exprp2(s))
		}
		Else Exprp1(ou,lf)
	}
	While,s<>""
	{
		t1:=Exprp2(s)
		If t1 In (,)
		Return
		Exprp1(ou,t1)
	}
	Return,ou
}

ExprEval(Byref e,Byref lp, Byref eo, Byref el)
{
	c1:=Chr(1)
	Loop,Parse,e,%c1%
	{
		lf:=A_LoopField,tt:=SubStr(lf,1,1),t:=SubStr(lf,2)
		While (RegExMatch(lf,"_&String\d+&_",rm))
		lf:=StrReplace(lf,rm,el[rm])
		If tt In l,v
		lf:=Exprp1(s,lf)
		Else{
			If tt=f
			t1:=InStr(t," "),a:=SubStr(t,1,t1-1),t:=SubStr(t,t1+1)
			Else a:=Exprac(t)
			Exprp1(s,Exprap(t,s,a,lp,eo))
		}
	}
	
	Loop,Parse,s,%c1%
	{
		lf:=A_LoopField
		If (SubStr(lf,1,1)="l"&&InStr(lf,"."))
		lf:=RTrim(lf,0), (SubStr(lf, 0)=".") ? lf:=SubStr(lf, 1, -1) 
		If (SubStr(lf,1,1)="v")
		t1:=SubStr(lf,2),r.=(lp[FD_CURRENT].HasKey(t1) ? lp[FD_CURRENT][t1] : %t1%) . c1
		Else r.=SubStr(lf,2) . c1
	}
	Return,SubStr(r,1,-1)
}

Exprap(o,ByRef s,ac,Byref lp, Byref eo)
{
	local i,t1,a1,a2,a3,a4,a5,a6,a1v,a2v,a3v,a4v,a5v,a6v,a7v,a8v,a9v
	Loop,%ac%
	i:=ac-(A_Index-1),t1:=Exprp2(s),a%i%:=SubStr(t1,2),(SubStr(t1,1,1)="v")?(a%i%v:=1)
	Loop, 10
	{
		If (RegExMatch(a%A_Index%,"^<~#(.*)#~>$",rm))
		a%A_Index%:=eo[rm1],a%A_Index%v:=0
		Else If (lp[FD_CURRENT].HasKey(a%A_Index%))
		key:=a%A_Index%,a%A_Index%:=lp[FD_CURRENT][a%A_Index%],a%A_Index%v:=0
	}
	If (skip_vars&&a1~=skip_vars)
	   Return
	If o=++
	Return,"l" . (key ? lp[FD_CURRENT][key]++ : %a1%++)
	If o=--
	Return,"l" . (key ? lp[FD_CURRENT][key]-- : %a1%--)
	If o=\++
	Return,"l" . (key ? ++lp[FD_CURRENT][key] : ++%a1%)
	If o=\--
	Return,"l" . (key ? --lp[FD_CURRENT][key] : --%a1%)
	If o=`%
	Return,"v" . %a1%
	If o=!
	Return,"l" . !(a1v ? %a1%:a1)
	If o=\!
	Return,"l" . (a1v ? %a1%:a1)
	If o=~
	Return,"l" . ~(a1v ? %a1%:a1)
	If o=**
	Return,"l" . ((a1v ? %a1%:a1)**(a2v ? %a2%:a2))
	If o=*
	Return,"l" . ((a1v ? %a1%:a1)*(a2v ? %a2%:a2))
	If o=\*
	Return,"l" . *(a1v ? %a1%:a1)
	If o=/
	Return,"l" . ((a1v ? %a1%:a1)/(a2v ? %a2%:a2))
	If o=//
	Return,"l" . ((a1v ? %a1%:a1)//(a2v ? %a2%:a2))
	If o=+
	Return,"l" . ((a1v ? %a1%:a1)+(a2v ? %a2%:a2))
	If o=-
	Return,"l" . ((a1v ? %a1%:a1)-(a2v ? %a2%:a2))
	If o=\-
	Return,"l" . -(a1v ? %a1%:a1)
	If o=<<
	Return,"l" . ((a1v ? %a1%:a1)<<(a2v ? %a2%:a2))
	If o=>>
	Return,"l" . ((a1v ? %a1%:a1)>>(a2v ? %a2%:a2))
	If o=&
	Return,"l" . ((a1v ? %a1%:a1)&(a2v ? %a2%:a2))
	If o=\&
	Return,"l" . &(a1v ? %a1%:a1)
	If o=^
	Return,"l" . ((a1v ? %a1%:a1)^(a2v ? %a2%:a2))
	If o=|
	Return,"l" . ((a1v ? %a1%:a1)|(a2v ? %a2%:a2))
	If o=\.
	Return,"l" . ((a1v ? %a1%:a1) . (a2v ? %a2%:a2))
	If o=.
	Return,"v" . a1
	If o=<
	Return,"l" . ((a1v ? %a1%:a1)<(a2v ? %a2%:a2))
	If o=>
	Return,"l" . ((a1v ? %a1%:a1)>(a2v ? %a2%:a2))
	If o==
	Return,"l" . ((a1v ? %a1%:a1)=(a2v ? %a2%:a2))
	If o===
	Return,"l" . ((a1v ? %a1%:a1)==(a2v ? %a2%:a2))
	If o=<>
	Return,"l" . ((a1v ? %a1%:a1)<>(a2v ? %a2%:a2))
	If o=~=
	Return,"l" . ((a1v ? %a1%:a1)~=(a2v ? %a2%:a2))
	If o=!=
	Return,"l" . ((a1v ? %a1%:a1)!=(a2v ? %a2%:a2))
	If o=>=
	Return,"l" . ((a1v ? %a1%:a1)>=(a2v ? %a2%:a2))
	If o=<=
	Return,"l" . ((a1v ? %a1%:a1)<=(a2v ? %a2%:a2))
	If o=&&
	Return,"l" . ((a1v ? %a1%:a1)&&(a2v ? %a2%:a2))
	If o=||
	Return,"l" . ((a1v ? %a1%:a1)||(a2v ? %a2%:a2))
	If o=:=
	{
		%a1%:=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=+=
	{
		%a1%+=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=-=
	{
		%a1%-=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=*=
	{
		%a1%*=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=/=
	{
		%a1%/=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=//=
	{
		%a1%//=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=.=
	{
		%a1%.=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=|=
	{
		%a1%|=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=&=
	{
		%a1%&=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=^=
	{
		%a1%^=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=>>=
	{
		%a1%>>=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=<<=
	{
		%a1%<<=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If ac=0
	Return,"l" . %o%()
	If ac=1
	Return,"l" . %o%(a1v ? %a1%:a1)
	If ac=2
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2))
	If ac=3
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3))
	If ac=4
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4))
	If ac=5
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5))
	If ac=6
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6))
	If ac=7
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6),(a7v ? %a7%:a7))
	If ac=8
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6),(a7v ? %a7%:a7),(a8v ? %a8%:a8))
	If ac=9
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6),(a7v ? %a7%:a7),(a8v ? %a8%:a8),(a9v ? %a9%:a9))
	If ac=10
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6),(a7v ? %a7%:a7),(a8v ? %a8%:a8),(a9v ? %a9%:a9),(a10v ? %a10%:a10))
}

Exprt(e)
{
	global Exprol
	c1:=Chr(1),f:=1,f1:=1
	While,(f:=RegExMatch(e,"S)""(?:[^""]|"""")*""",m,f))
	{
		t1:=SubStr(m,2,-1)
	,	t1:=StrReplace(t1,"""""","""")
	,	t1:=StrReplace(t1,"'","'27")
	,	t1:=StrReplace(t1,"````",c1)
	,	t1:=StrReplace(t1,"``n","`n")
	,	t1:=StrReplace(t1,"``r","`r")
	,	t1:=StrReplace(t1,"``b","`b")
	,	t1:=StrReplace(t1,"``t","`t")
	,	t1:=StrReplace(t1,"``v","`v")
	,	t1:=StrReplace(t1,"``a","`a")
	,	t1:=StrReplace(t1,"``f","`f")
	,	t1:=StrReplace(t1,c1,"``")
		SetFormat,IntegerFast,Hex
		While,RegExMatch(t1,"iS)[^\w']",c)
		t1:=StrReplace(t1,c,"'" . SubStr("0" . SubStr(Asc(c),3),-1))
		SetFormat,IntegerFast,D
		e1.=SubStr(e,f1,f-f1) . c1 . "l" . t1 . c1,f+=StrLen(m),f1:=f
	}
	e1.=SubStr(e,f1),e:=InStr(e1,"""")? "":e1,e1:="",e:=RegExReplace(e,"S)/\*.*?\*/|[ \t]`;.*?(?=\r|\n|$)")
,	e:=StrReplace(e,"`t"," ")
,	e:=RegExReplace(e,"S)([\w#@\$] +|\) *)(?=" . Chr(1) . "*[\w#@\$\(])","$1 . ")
,	e:=StrReplace(e," . ","\.")
,	e:=StrReplace(e," ")
,	f:=1,f1:=1
	While,(f:=RegExMatch(e,"iS)(^|[^\w#@\$\.'])(0x[0-9a-fA-F]+|\d+(?:\.\d+)?|\.\d+)(?=[^\d\.]|$)",m,f))
	{
		If ((m1="\") && (RegExMatch(m2,"\.\d+")))
		m1:="",m2:=SubStr(m2,2)
		m2+=0
		m2:=StrReplace(m2,".","'2E",,1)
		e1.=SubStr(e,f1,f-f1) . m1 . c1 . "n" . m2 . c1,f+=StrLen(m),f1:=f
	}
	e:=e1 . SubStr(e,f1),e1:="" ; ,e:=RegExReplace(e,"S)(^|\(|[^" . c1 . "-])-" . c1 . "n","$1" . c1 . "n'2D")
,	e:=StrReplace(e,c1 "n",c1 "l")
,	e:=RegExReplace(e,"\\\.(\d+)\.(\d+)",c1 . "l$1'2E$2" . c1)
,	e:=RegExReplace(RegExReplace(e,"S)(%[\w#@\$]{1,253})%","$1"),"S)(?:^|[^\w#@\$'" . c1 . "])\K[\w#@\$]{1,253}(?=[^\(\w#@\$]|$)",c1 . "v$0" . c1),f:=1,f1:=1
	While,(f:=RegExMatch(e,"S)(^|[^\w#@\$'])([\w#@\$]{1,253})(?=\()",m,f))
	{
		t1:=f+StrLen(m)
		If (SubStr(e,t1+1,1)=")")
		ac=0
		Else
		{
			If !Exprmlb(e,t1,fa)
			Return
			fa:=StrReplace(fa,"`,","`,",c)
			ac:=c+1
		}
		e1.=SubStr(e,f1,f-f1) . m1 . c1 . "f" . ac . "'20" . m2 . c1,f+=StrLen(m),f1:=f
	}
	e:=e1 . SubStr(e,f1),e1:=""
,	e:=StrReplace(e,"\." c1 "vNot" c1 "\.","!")
,	e:=StrReplace(e,"\." c1 "vAnd" c1 "\.","&&")
,	e:=StrReplace(e,"\." c1 "vOr" c1 "\.","||")
,	e:=StrReplace(e,c1 "vNot" c1 "\.","!")
,	e:=StrReplace(e,c1 "vAnd" c1 "\.","&&")
,	e:=StrReplace(e,c1 "vOr" c1 "\.","||")
,	e:=StrReplace(e,"\." c1 "vNot" c1 . c1,"!")
,	e:=StrReplace(e,"\." c1 "vAnd" c1 . c1,"&&")
,	e:=StrReplace(e,"\." c1 "vOr" c1 . c1,"||")
,	e:=StrReplace(e,c1 "vNot" c1 . c1,"!")
,	e:=StrReplace(e,c1 "vAnd" c1 . c1,"&&")
,	e:=StrReplace(e,c1 "vOr" c1 . c1,"||")
,	e:=RegExReplace(e,"S)(^|[^" . c1 . "\)-])-" . c1 . "(?=[lvf])","$1\-" . c1)
,	e:=RegExReplace(e,"S)(^|[^" . c1 . "\)&])&" . c1 . "(?=[lvf])","$1\&" . c1)
,	e:=RegExReplace(e,"S)(^|[^" . c1 . "\)\*])\*" . c1 . "(?=[lvf])","$1\*" . c1)
,	e:=RegExReplace(e,"S)(^|[^" . c1 . "\)])(\+\+|--)" . c1 . "(?=[lvf])","$1\$2" . c1)
,	t1:=RegExReplace(Exprol,"S)[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0")
,	t1:=StrReplace(t1,"`n","|")
,	e:=RegExReplace(e,"S)" . t1,c1 . "o$0" . c1)
,	e:=StrReplace(e,"`,",c1 "`," c1)
,	e:=StrReplace(e,"(",c1 "(" c1)
,	e:=StrReplace(e,")",c1 ")" c1)
,	e:=StrReplace(e,c1 . c1,c1)
	If RegExMatch(e,"S)" . c1 . "[^lvfo\(\),\n]")
	Return
	e:=SubStr(e,2,-1),f:=0
	While,(f:=InStr(e,"'",False,f + 1))
	{
		If ((t1:=SubStr(e,f+1,2))<>27)
		e:=StrReplace(e,"'" t1,Chr("0x" . t1))
	}
	e:=StrReplace(e,"'27","'")
	Return,e
}

Exprols(o1,o2)
{
	Return,StrLen(o2)-StrLen(o1)
}

Exprpr(o)
{
	global Exprot
	t:=InStr(Exprot,"`n" . o . " ")+StrLen(o)+2
	Return,SubStr(Exprot,t,InStr(Exprot," ",0,t)-t)
}

Expras(o)
{
	global Exprot
	Return,SubStr(Exprot,InStr(Exprot," ",0,InStr(Exprot,"`n" . o . " ")+StrLen(o)+2)+1,1)
}

Exprac(o)
{
	global Exprot
	Return,SubStr(Exprot,InStr(Exprot,"`n",0,InStr(Exprot,"`n" . o . " ")+1)-1,1)
}

Exprmlb(ByRef s,p,ByRef o="",b="(",e=")")
{
	t:=SubStr(s,p),bc:=0,VarSetCapacity(o,StrLen(t))
	If (SubStr(t,1,1)<>b)
	Return,0
	Loop,Parse,t
	{
		lf:=A_LoopField
		If lf=%b%
		bc++
		Else If lf=%e%
		{
			bc--
			If bc=0
			Return,p
		}
		Else If bc=1
		o.=lf
		p++
	}
	Return,0
}

Exprp1(ByRef dl,d)
{
	dl.=((dl="")? "":Chr(1)) . d
}

Exprp2(ByRef dl)
{
	t:=InStr(dl,Chr(1),0,0),t ?(t1:=SubStr(dl,t+1),dl:=SubStr(dl,1,t-1)):(t1:=dl,dl:="")
	Return,t1
}

Exprp3(ByRef dl)
{
	Return,SubStr(dl,InStr(dl,Chr(1),0,0)+1)
}