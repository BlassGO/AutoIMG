
;By teadrinker --> https://www.autohotkey.com/boards/viewtopic.php?t=41491

GetHBitmapFromImageURL(url)  {
   oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   oWhr.Open("GET", url, false)
   oWhr.Send()
   if (oWhr.Status != 200)  {
      MsgBox, Failed to load the image!
      Return
   }
   contentType := oWhr.GetResponseHeader("Content-Type")
   if !InStr(contentType, "image")  {
      MsgBox, URL doesn't link to an image!
      Return
   }
   Return (new GDIp).HBitmapFromIStream(oWhr.ResponseStream)
}

class GDIp   {
   __New() {
      if !DllCall("GetModuleHandle", Str, "gdiplus", Ptr)
         DllCall("LoadLibrary", Str, "gdiplus")
      VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
      DllCall("gdiplus\GdiplusStartup", UPtrP, pToken, Ptr, &si, Ptr, 0)
      this.token := pToken
   }
   
   __Delete()  {
      DllCall("gdiplus\GdiplusShutdown", Ptr, this.token)
      if hModule := DllCall("GetModuleHandle", Str, "gdiplus", Ptr)
         DllCall("FreeLibrary", Ptr, hModule)
   }
   
   HBitmapFromIStream(IStream)  {
      pStream := ComObjQuery(IStream, "{0000000C-0000-0000-C000-000000000046}")
      DllCall("gdiplus\GdipCreateBitmapFromStream", Ptr, pStream, PtrP, pBitmap)
      ObjRelease(pStream)
      DllCall("OleAut32\VariantClear", PtrP, IStream)
      DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", Ptr, pBitmap, PtrP, hBitmap, UInt, 0xFFFFFFFF)
      DllCall("gdiplus\GdipDisposeImage", Ptr, pBitmap)
      Return hBitmap
   }
}

SavePicture(hBM, sFile) {                                            ; By SKAN on D293 @ bit.ly/2krOIc9
Local V,  pBM := VarSetCapacity(V,16,0)>>8,  Ext := LTrim(SubStr(sFile,-3),"."),  E := [0,0,0,0]
Local Enc := 0x557CF400 | Round({"bmp":0, "jpg":1,"jpeg":1,"gif":2,"tif":5,"tiff":5,"png":6}[Ext])
  E[1] := DllCall("gdi32\GetObjectType", "Ptr",hBM ) <> 7
  E[2] := E[1] ? 0 : DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr",hBM, "UInt",0, "PtrP",pBM)
  NumPut(0x2EF31EF8,NumPut(0x0000739A,NumPut(0x11D31A04,NumPut(Enc+0,V,"UInt"),"UInt"),"UInt"),"UInt")
  E[3] := pBM ? DllCall("gdiplus\GdipSaveImageToFile", "Ptr",pBM, "WStr",sFile, "Ptr",&V, "UInt",0) : 1
  E[4] := pBM ? DllCall("gdiplus\GdipDisposeImage", "Ptr",pBM) : 1
Return E[1] ? 0 : E[2] ? -1 : E[3] ? -2 : E[4] ? -3 : 1  
}