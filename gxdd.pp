{
    This file is a part of the graphics library GraphiX
    Copyright (C) 2001 Michael Knapp

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{$I gxglobal.cfg}
UNIT gxdd;

INTERFACE

{$MODE DELPHI}

USES gxcrtext,gxtype,gxbase,windows,directdraw,sysutils,directdrawfpc,strings,gxmouse,gxsup;
{$I gxlocal.cfg}

TYPE PSpecSurface=^TSpecSurface;
     TSpecSurface=RECORD
       DDS:IDirectDrawSurface;
     END;

FUNCTION DDInit(hInst:THANDLE;nCmdShow:integer):HResult;
FUNCTION DDDone:HResult;
FUNCTION DDInitMode(xres,yres,bpp:longint):HResult;
FUNCTION DDDoneMode:HResult;
FUNCTION DDScanModes(var modelist:PModeEntry):HResult;
FUNCTION DDGetPrimarySurfaceDesc(var bpl:dword;var Rp,Rs,Gp,Gs,Bp,Bs:byte):HResult;
FUNCTION DDLock:HResult;
FUNCTION DDUnlock:HResult;
PROCEDURE DDblankstart;
PROCEDURE DDblankend;
PROCEDURE DDHandleMessages;
{PROCEDURE DDSetPalette332;}
FUNCTION DDGetMouseX:longint;
FUNCTION DDGetMouseY:longint;
FUNCTION DDGetMouseRelX:longint;
FUNCTION DDGetMouseRelY:longint;
FUNCTION DDGetMouseButton:byte;
FUNCTION DDSetMouseCallback(cb:pointer);
FUNCTION ROPsupported(rop:dword):boolean;
PROCEDURE DDsethwaprocs(col:longint);

PROCEDURE retrace_dd;
PROCEDURE retraceend_dd;
PROCEDURE retracestart_dd;
PROCEDURE setrgbcolor_dd(i,r,g,b:byte);
PROCEDURE graphwin_dd(x1,y1,x2,y2:longint);
PROCEDURE lineh_dd(x1,x2,y,f:longint);
PROCEDURE linev_dd(x,y1,y2,f:longint);
PROCEDURE bar_dd(x1,y1,x2,y2,f:longint);
PROCEDURE barxor_dd(x1,y1,x2,y2,f:longint);
PROCEDURE moverect_dd(x1,y1,x2,y2,x,y:longint);

FUNCTION CreateSpecSurface(w,h,bpl:longint;flags:dword;var sp:pointer;var ss:TSpecSurface):boolean;
FUNCTION DestroySpecSurface(var ss:TSpecSurface):boolean;
FUNCTION DDEnableSurfaceFlipping(var bs:TSpecSurface):boolean;
FUNCTION DDFlipSurface(waitforverticalretrace:boolean):boolean;
FUNCTION DDDisableSurfaceFlipping(var bs:TSpecSurface):boolean;

PROCEDURE InitVideoMem(vmb,vms,omb,oms:dword);
PROCEDURE DDGetPrimarySurface(var DDS:IDirectDrawSurface);
FUNCTION DDGetSurfacePointer(var ss:TSpecSurface):pointer;

FUNCTION DDkeypressed:boolean;
FUNCTION DDreadkey:char;
PROCEDURE DDdelay(ms:word);

VAR GXhwnd:HWND;

IMPLEMENTATION

USES graphix;

CONST charbufsize=32;
      getcharidx:longint=1;
      putcharidx:longint=1;
      charbuffull:boolean=FALSE;
      charbufempty:boolean=TRUE;

VAR charbuf:array[1..32] of char;

FUNCTION putchar(ch:char):boolean;
BEGIN
  putchar:=FALSE;
  IF NOT charbuffull THEN
    BEGIN
      putchar:=TRUE;
      charbuf[putcharidx]:=ch;
      inc(putcharidx);
      IF (putcharidx>charbufsize) THEN putcharidx:=1;
      charbufempty:=FALSE;
      charbuffull:=(getcharidx=putcharidx);
    END;
END;

FUNCTION getchar(var ch:char):boolean;
BEGIN
  getchar:=FALSE;
  IF NOT charbufempty THEN
    BEGIN
      getchar:=TRUE;
      ch:=charbuf[getcharidx];
      inc(getcharidx);
      IF (getcharidx>charbufsize) THEN getcharidx:=1;
      charbuffull:=FALSE;
      charbufempty:=(getcharidx=putcharidx);
    END;
END;

FUNCTION DDkeypressed:boolean;
BEGIN
  DDHandleMessages;
  DDkeypressed:=NOT charbufempty;
END;

FUNCTION DDreadkey:char;
VAR ch:char;
BEGIN
  DDHandleMessages;
  WHILE NOT getchar(ch) DO DDHandleMessages;
  DDreadkey:=ch;
END;

PROCEDURE DDdelay(ms:word);
BEGIN
  sleep(ms);
END;

{----------------------------------------------------------------------------}

CONST
  NAME :PChar = 'GraphiX';
  TITLE:PChar = vergxname+' v'+vergxmajornum+'.'+vergxminornum;

VAR GXpDD         :IDirectDraw;                { DirectDraw object }
    GXpDDSPrimary :IDirectDrawSurface;         { DirectDraw primary surface }
    GXpDDSBack    :IDirectDrawSurface;         { DirectDraw back surface }
    GXpDDSDraw    :IDirectDrawSurface;         { DirectDraw back surface }
    GXpDDSPattern :IDirectDrawSurface;
    GXpDDP        :IDirectDrawPalette;
    GXpDDC        :IDirectDrawClipper;
    GXSDMdwWidth:dword;
    GXSDMdwHeight:dword;
    GXSDMdwBPP:dword;

VAR DDactive,DDmode,DDlocked:boolean;
    IsInit:boolean;
    DDclip:Prgndata;
    DDcr:PRect;
    DDbltFX:TDDbltFX;
    DDcaps:TDDcaps;
    GXmx,GXmy,GXamx,GXamy:longint;
    GXmb:byte;
    GXMouseCallbackUsed:boolean;
    GXMouseCallBack:procedure;

CONST GXbActive:Boolean=False; { Is application active? }

FUNCTION InitFail(h_Wnd:HWND;hRet:HRESULT;Text:string):HRESULT;
BEGIN
  MessageBox(h_Wnd,PChar(Text+': '+DDErrorString(hRet)),TITLE,MB_OK);
  DDDone;
  DestroyWindow(h_Wnd);
  Result:=hRet;
END;

CONST GXToRestore:boolean=FALSE;
      GXbuff:pimage=NIL;

FUNCTION DDBackUp:HResult;
VAR ddsd:TDDSurfaceDesc;
    hret:HRESULT;
BEGIN
  IF NOT GXToRestore THEN
    BEGIN
      FillChar(ddsd,SizeOf(ddsd),0);
      ddsd.dwSize:=SizeOf(ddsd);
      hRet:=IDirectDraw_GetDisplayMode(GXpDD,ddsd);
      IF (hret=DD_OK) THEN
        IF (ddsd.dwWidth=GXSDMdwWidth) AND
           (ddsd.dwHeight=GXSDMdwHeight) AND
           (ddsd.ddpfPixelFormat.dwRGBBitCount=GXSDMdwBPP) THEN
          BEGIN
            GXToRestore:=TRUE;
            GXbuff:=CreateImageWH(getmaxX+1,getmaxY+1);
            mouseoff;
            pushgraphwin;
            maxgraphwin;
            getimage(0,0,GXbuff);
            popgraphwin;
          END;
    END;
  Result:=DD_OK;
END;

FUNCTION DDRestore:HResult;
VAR hret:HRESULT;
BEGIN
  IF GXToRestore THEN
    BEGIN
      hRet:=IDirectDraw_SetDisplayMode(GXpDD,GXSDMdwWidth,GXSDMdwHeight,GXSDMdwBPP);
      IF (hRet<>DD_OK) THEN
        BEGIN
          result:=InitFail(GXhwnd,hRet,'SetDisplayMode FAILED');
          Exit;
        END;
      IF (IDirectDrawSurface_IsLost(GXpDDSPrimary)=DDERR_SURFACELOST) THEN
        BEGIN
          hret:=IDirectDrawSurface__Restore(GXpDDSPrimary);
          IF (hRet<>DD_OK) THEN
            BEGIN
              result:=InitFail(GXhwnd,hRet,'_Restore(Primary) FAILED');
              Exit;
            END;
        END;
      DDLock;
      DDUnLock;
      pushgraphwin;
      maxgraphwin;
      putimage(0,0,GXbuff);
      popgraphwin;
      destroyimage(GXbuff);
      mouseon;
      GXToRestore:=FALSE;
    END;
  Result:=DD_OK;
END;

PROCEDURE PrntStr(h_wnd:HWND;x,y:longint;txt:string);
VAR h_DC:HDC;
    c:pchar;
BEGIN
  H_DC:=getDC(h_wnd);
  c:=StrAlloc(length(txt)+1);
  strpcopy(c,txt);
  SetBkColor(h_DC, RGB(0, 0, 0));
  SetTextColor(h_DC, RGB(255, 255, 255));
  TextOut(h_DC,x,y,c,StrLen(c));
  releaseDC(h_wnd,h_dc);
END;

FUNCTION WindowProc(h_Wnd:HWND;aMSG:Cardinal;wParam:Cardinal;lParam:Integer):Integer;stdcall;
VAR hRet:HRESULT;
    ret,i,j:integer;
    kbstate:array[0..255] of byte;
    keybuffer:word;
BEGIN
  CASE aMSG OF
    {===== Pause if minimized }
    WM_ACTIVATE:
      BEGIN
        IF GraphiXActive THEN DDBackUp;
        GXbActive:=(HIWORD(wParam)=0);
        Result:=0;
        Exit;
      END;
    {====== }
    WM_ACTIVATEAPP:
      BEGIN
     {   PrntStr(h_wnd,50,50,'Backup/Restore '+hexlong(wParam)+' '+hexlong(lParam)+' '+hexlong(h_wnd)); }
        IF GraphiXActive THEN IF (wParam<>0) THEN DDRestore;
        Result:=0;
        exit;
      END;
    {===== Clean up and close the app }
    WM_DESTROY:
      BEGIN
        DDDone;
        PostQuitMessage(0);
        Result:=0;
        Exit;
      END;
    {===== Handle any non-accelerated key commands }
    WM_KEYDOWN:
      BEGIN
        GetKeyboardState(@kbstate);
        ret:=ToASCII(wparam AND $FF,(lParam SHR 16) AND $FF,@kbstate,@keybuffer,0);
        CASE ret OF
        0:BEGIN
            putchar(#0);
            putchar(chr((lParam SHR 16) AND $FF));
          END;
        1:BEGIN
            putchar(chr(keybuffer AND $FF));
          END;
        END;
      END;
    {===== Turn off the cursor since this is a full-screen app }
    WM_SETCURSOR:
      BEGIN
        SetCursor(0);
        SetCapture(h_wnd);
    {    PrintString(random(400),random(300),'WM_SETCURSOR'); }
        Result:=1;
        Exit;
      END;
    WM_LBUTTONDOWN,
    WM_MBUTTONDOWN,
    WM_RBUTTONDOWN,
    WM_LBUTTONUP,
    WM_MBUTTONUP,
    WM_RBUTTONUP,
    WM_MOUSEMOVE:
      BEGIN
{PrintString(300,200,long2str(loword(lparam)));
PrintString(300,220,long2str(hiword(lparam)));
PrintString(300,240,long2str(wParam));}
      {  GetClientRect(h_wnd,@Rect);
        GXmx:=loword(lparam)+Rect.left;
        GXmy:=hiword(lparam)+Rect.top; }
        GXmx:=loword(lparam);
        GXmy:=hiword(lparam);
        GXmb:=0;
        IF (wParam<>0) THEN
          BEGIN
            IF (wParam AND MK_LBUTTON<>0) THEN GXmb:=GXmb OR $01;
            IF (wParam AND MK_RBUTTON<>0) THEN GXmb:=GXmb OR $02;
            IF (wParam AND MK_MBUTTON<>0) THEN GXmb:=GXmb OR $04;
          END;
        IF GXMouseCallbackUsed THEN GXMouseCallback;
      {  IF NOT GraphiXActive THEN
          BEGIN
            GXamx:=GXmx;
            GXamy:=GXmy;
          END; }

        Result:=0;
        Exit;
      END;
    END;
  Result:=DefWindowProc(h_Wnd,aMSG,wParam,lParam);
END;

FUNCTION DDInit(hInst:THANDLE;nCmdShow:integer):HResult;
VAR wc:WNDCLASS;
    ddsd:TDDSurfaceDesc;
    ddscaps:TDDSCaps2;
    dddi:TDDDeviceIdentifier;
    hRet:HRESULT;
 {   pDDTemp:IDirectDraw; }
    i:integer;
BEGIN
  GXMouseCallbackUsed:=FALSE;
{===== Set up and register window class }
  wc.style:=CS_HREDRAW OR CS_VREDRAW;
  wc.lpfnWndProc:=@WindowProc;
  wc.cbClsExtra:=0;
  wc.cbWndExtra:=0;
  wc.hInstance:=hInst;
  wc.hIcon:=LoadIcon(hInst,'MAINICON');
  wc.hCursor:=LoadCursor(0,IDC_ARROW);
  wc.hbrBackground:=GetStockObject(NULL_BRUSH);
  wc.lpszMenuName:=NAME;
  wc.lpszClassName:=NAME;
  RegisterClass(wc);
{===== Create a window }
  GXhwnd:=CreateWindowEx(WS_EX_TOPMOST,NAME,TITLE,WS_POPUP,0,0,GetSystemMetrics(SM_CXSCREEN),GetSystemMetrics(SM_CYSCREEN),0,0,hInst,nil);
  IF (GXhwnd=0) THEN
    BEGIN
      Result:=0;
      exit;
    END;
  ShowWindow(GXhwnd,nCmdShow);
  UpdateWindow(GXhwnd);
  SetFocus(GXhwnd);
  SetCapture(GXhwnd);
{===== Create the main DirectDraw object }
  hRet:=DirectDrawCreate(nil,GXpDD{Temp},nil);
  IF (hRet<>DD_OK) THEN
    BEGIN
      result:=InitFail(GXhwnd,hRet,'DirectDrawCreate FAILED');
      exit;
    END;
{===== Get exclusive mode }
  hRet:=IDirectDraw_SetCooperativeLevel(GXpDD,GXhwnd,DDSCL_EXCLUSIVE OR DDSCL_FULLSCREEN);
  IF (hRet<>DD_OK) THEN
    BEGIN
      Result:=InitFail(GXhwnd,hRet,'SetCooperativeLevel FAILED');
      Exit;
    END;
{===== Creating Clipper Structure }
  getmem(DDclip,sizeof(trgndata)+sizeof(trect));
  DDclip^.rdh.dwSize:=sizeof(trgndataheader);
  DDclip^.rdh.iType:=RDH_RECTANGLES;
  DDclip^.rdh.nCount:=1;
  DDclip^.rdh.nRgnSize:=sizeof(trect);
  DDcr:=pointer(dword(DDclip)+sizeof(trgndataheader));
{===== Clearing Structures }
  fillchar(DDbltFX,sizeof(DDbltFX),0);
  DDbltFX.dwSize:=sizeof(DDbltFX);
{=====}
  DDactive:=TRUE;
  DDmode:=FALSE;
  DDlocked:=FALSE;
  IsInit:=TRUE;
END;

FUNCTION DDDone:HResult;
VAR aMSG:MSG;
BEGIN
  IF NOT IsInit THEN exit;
  IsInit:=FALSE;
  DDUnlock;
  IF DDmode THEN DDDoneMode;
  IF Assigned(GXpDD) THEN
    BEGIN
      GXpDD:=nil;
    END;
  freemem(DDclip,sizeof(trgndata)+sizeof(trect));
  DDactive:=FALSE;
  DDmode:=FALSE;
  DDlocked:=FALSE;
{  ReleaseCapture;
  PostMessage(GXhwnd,WM_CLOSE,0,0);
  DDHandleMessages; }
  result:=DD_OK;
END;

FUNCTION DDInitMode(xres,yres,bpp:longint):HResult;
VAR hRet:HRESULT;
    ddsd:TDDSurfaceDesc;
    ddscaps:TDDSCaps2;
    pal:array[0..255] of PALETTEENTRY;
    r,g,b,i:word;
BEGIN
  GXSDMdwWidth:=xres;
  GXSDMdwHeight:=yres;
  GXSDMdwBPP:=bpp;
  IF DDmode THEN DDDoneMode;
  hRet:=IDirectDraw_SetDisplayMode(GXpDD,GXSDMdwWidth,GXSDMdwHeight,GXSDMdwBPP);
  IF (hRet<>DD_OK) THEN
    BEGIN
      Result:=InitFail(GXhwnd,hRet,'SetDisplayMode FAILED');
      Exit;
    END;
{===== Get Caps }
  fillchar(DDcaps,sizeof(DDcaps),0);
  DDcaps.dwSize:=sizeof(DDcaps);
  hret:=IDirectDraw_GetCaps(GXpDD,@DDcaps,nil);
  IF (hRet<>DD_OK) THEN
    BEGIN
      Result:=InitFail(GXhwnd,hRet,'GetCaps FAILED');
      Exit;
    END;
{===== Create the primary surface }
  FillChar(ddsd,SizeOf(ddsd),0);
  ddsd.dwSize:=SizeOf(ddsd);
  ddsd.dwFlags:=DDSD_CAPS;
  ddsd.ddsCaps.dwCaps:=DDSCAPS_PRIMARYSURFACE;
  hRet:=IDirectDraw_CreateSurface(GXpDD,ddsd,GXpDDSPrimary,nil);
  IF (hRet<>DD_OK) THEN
    BEGIN
      Result:=InitFail(GXhwnd,hRet,'CreateSurface(Primary) FAILED');
      Exit;
    END;
  GXpDDSDraw:=GXpDDSPrimary;
  hret:=IDirectDraw_CreatePalette(GXpDD,DDPCAPS_8BIT OR DDPCAPS_ALLOW256,@pal,GXpDDP,nil);
  IF (hRet<>DD_OK) THEN
    BEGIN
      Result:=InitFail(GXhwnd,hRet,'CreatePalette FAILED');
      Exit;
    END;
{===== CreateClipper }
  DDclip^.rdh.rcBound.left:=0;
  DDclip^.rdh.rcBound.top:=0;
  DDclip^.rdh.rcBound.right:=xres;
  DDclip^.rdh.rcBound.bottom:=yres;
  hret:=IDirectDraw_CreateClipper(GXpDD,0,GXpDDC,nil);
  IF (hRet<>DD_OK) THEN
    BEGIN
      Result:=InitFail(GXhwnd,hRet,'CreateClipper FAILED');
      Exit;
    END;
  hret:=IDirectDrawSurface_SetClipper(GXpDDSPrimary,GXpDDC);
  IF (hRet<>DD_OK) THEN
    BEGIN
      Result:=InitFail(GXhwnd,hRet,'SetClipper(Primary) FAILED');
      Exit;
    END;
{=====}
  DDmode:=TRUE;
  SetCursor(0);
END;

FUNCTION DDDoneMode:HResult;
BEGIN
  IF DDmode THEN
    BEGIN
      IF Assigned(GXpDDSPrimary) THEN
        BEGIN
          IDirectDrawSurface_Release(GXpDDSPrimary);
          GXpDDSPrimary:=nil;
        END;
      IF Assigned(GXpDDSBack) THEN
        BEGIN
          IDirectDrawSurface_Release(GXpDDSBack);
          GXpDDSBack:=nil;
        END;
      IF Assigned(GXpDDP) THEN
        BEGIN
          IDirectDrawPalette_Release(GXpDDP);
          GXpDDP:=nil;
        END;
      IF Assigned(GXpDDC) THEN
        BEGIN
          IDirectDrawClipper_Release(GXpDDC);
          GXpDDC:=nil;
        END;
      DDmode:=FALSE;
    END;
  result:=DD_OK;
END;

FUNCTION getfirstbit(l:dword):longint;
VAR i:longint;
BEGIN
  i:=-1;
  IF (l<>0) THEN
    BEGIN
      i:=0;
      WHILE (l AND 1=0) AND (i<32) DO
        BEGIN
          inc(i);
          l:=l SHR 1;
        END;
    END;
  getfirstbit:=i;
END;

FUNCTION getlastbit(l:dword):longint;
VAR i:longint;
BEGIN
  i:=-1;
  IF (l<>0) THEN
    BEGIN
      i:=32;
      WHILE (l AND $80000000=0) AND (i>0) DO
        BEGIN
          dec(i);
          l:=l SHL 1;
        END;
    END;
  getlastbit:=i;
END;

FUNCTION DDEnumModesCallback(const lpddsd:TDDSurfaceDesc;lpContext:pointer):HRESULT;stdcall;
VAR col,Rp,Rs,Gp,Gs,Bp,Bs:longint;
    cf,bf:boolean;
    s:string;
    c:pchar;
BEGIN
  IF (lpddsd.dwFlags AND DDSD_WIDTH=DDSD_WIDTH) AND
     (lpddsd.dwFlags AND DDSD_HEIGHT=DDSD_HEIGHT) AND
     (lpddsd.dwFlags AND DDSD_PITCH=DDSD_PITCH) AND
     (lpddsd.dwFlags AND DDSD_PIXELFORMAT=DDSD_PIXELFORMAT) THEN
    BEGIN
      cf:=FALSE;
      bf:=FALSE;
      col:=0;
      IF (lpddsd.ddpfpixelformat.dwFlags AND DDPF_RGB=DDPF_RGB) THEN
        BEGIN
          Rp:=getfirstbit(lpddsd.ddpfpixelformat.dwRBitMask);
          Rs:=getlastbit(lpddsd.ddpfpixelformat.dwRBitMask)-Rp;
          Gp:=getfirstbit(lpddsd.ddpfpixelformat.dwGBitMask);
          Gs:=getlastbit(lpddsd.ddpfpixelformat.dwGBitMask)-Gp;
          Bp:=getfirstbit(lpddsd.ddpfpixelformat.dwBBitMask);
          Bs:=getlastbit(lpddsd.ddpfpixelformat.dwBBitMask)-Bp;
          cf:=TRUE;
        END;
      CASE lpddsd.ddpfpixelformat.dwRGBbitCount OF
        8:BEGIN Rp:=5;Rs:=3;Gp:=2;Gs:=3;Bp:=0;Bs:=2; END;
      END;
      CASE lpddsd.ddpfpixelformat.dwRGBbitCount OF
        8:col:=ig_col8;
       15:col:=ig_col15;
       16:col:=ig_col16;
       24:col:=ig_col24;
       32:col:=ig_col32;
      END;
      bf:=(col<>0);

{s:=long2str(lpddsd.dwWidth)+'x'+long2str(lpddsd.dwHeight)+'x'+long2str(lpddsd.ddpfpixelformat.dwRGBbitCount)+' - '+
   long2str(Rp)+':'+long2str(Rs)+'/'+
   long2str(Gp)+':'+long2str(Gs)+'/'+
   long2str(Bp)+':'+long2str(Bs);
c:=stralloc(length(s)+1);
MessageBox(GXhwnd,strpcopy(c,s),TITLE,MB_OK); }

      IF cf AND bf THEN AddModeToList(PModeEntry(lpContext^),
                                      lpddsd.ddpfpixelformat.dwRGBbitCount,
                                      lpddsd.dwWidth,
                                      lpddsd.dwHeight,
                                      (lpddsd.ddpfpixelformat.dwRGBbitCount+7) DIV 8,
                                      lpddsd.lPitch,
                                      0,0,0,
                                      Rp,Rs,Gp,Gs,Bp,Bs, ig_bank+ig_lfb+ig_hwa+col);
    END;
  DDEnumModesCallback:=DDENUMRET_OK;
END;

FUNCTION DDScanModes(var modelist:PModeEntry):HResult;
VAR hret:HRESULT;
BEGIN
  result:=DD_OK;
  hret:=IDirectDraw_EnumDisplayModes(GXpDD,0,nil,@modelist,@DDEnumModesCallBack);
  IF (hret<>0) THEN
    BEGIN
      result:=InitFail(GXhwnd,hRet,'EnumDisplayModes FAILED');
    END;
END;

FUNCTION DDGetPrimarySurfaceDesc(var bpl:dword;var Rp,Rs,Gp,Gs,Bp,Bs:byte):HResult;
VAR hret:HResult;
    ddsd:TDDSurfaceDesc;
BEGIN
  fillchar(ddsd,sizeof(ddsd),0);
  ddsd.dwSize:=sizeof(ddsd);
  hret:=IDirectDrawSurface_GetSurfaceDesc(GXpDDSPrimary,ddsd);
  IF (hret=DD_OK) THEN
    BEGIN
      IF (ddsd.dwFlags AND DDSD_PITCH=DDSD_PITCH) THEN
        bpl:=ddsd.lpitch;
      IF (ddsd.dwFlags AND DDSD_PIXELFORMAT=DDSD_PIXELFORMAT) THEN
        IF (ddsd.ddpfpixelformat.dwFlags AND DDPF_RGB=DDPF_RGB) AND
           (ddsd.ddpfpixelformat.dwRGBBitCount>8) THEN
          BEGIN
            Rp:=getfirstbit(ddsd.ddpfpixelformat.dwRBitMask);
            Rs:=getlastbit(ddsd.ddpfpixelformat.dwRBitMask)-Rp;
            Gp:=getfirstbit(ddsd.ddpfpixelformat.dwGBitMask);
            Gs:=getlastbit(ddsd.ddpfpixelformat.dwGBitMask)-Gp;
            Bp:=getfirstbit(ddsd.ddpfpixelformat.dwBBitMask);
            Bs:=getlastbit(ddsd.ddpfpixelformat.dwBBitMask)-Bp;
          END;
    END;
END;

PROCEDURE setrgbcolor_DD(i,r,g,b:byte);
VAR col:dword;
BEGIN
  col:=(dword(b) SHL 16)+(dword(g) SHL 8)+r;
  IDirectDrawPalette_SetEntries(GXpDDP,0,i,1,@col);
  IDirectDrawSurface_SetPalette(GXpDDSPrimary,GXpDDP);
END;

FUNCTION DDLock:HResult;
VAR hret:HResult;
    ddsd:TDDSurfaceDesc;
BEGIN
  IF DDlocked THEN exit;
  fillchar(ddsd,sizeof(ddsd),0);
  ddsd.dwSize:=sizeof(ddsd);
  hret:=IDirectDrawSurface_Lock(GXpDDSPrimary,nil,ddsd,DDLOCK_SURFACEMEMORYPTR OR DDLOCK_WAIT,0);
  IF (hret=DD_OK) THEN
    BEGIN
      LFBbase:=dword(ddsd.lpSurface);
      LFBoffs:=dword(ddsd.lpSurface);
      VGAbase:=dword(ddsd.lpSurface);
      DDlocked:=TRUE;
      result:=DD_OK;
    END
  ELSE
    BEGIN
      result:=InitFail(GXhwnd,hRet,'Lock FAILED');
      exit;
    END;
END;

FUNCTION DDUnlock:HResult;
VAR hret:HResult;
BEGIN
  IF NOT DDlocked THEN exit;
  hret:=IDirectDrawSurface_UnLock(GXpDDSPrimary,nil);
  IF (hret=DD_OK) THEN
    BEGIN
      DDlocked:=FALSE;
      result:=DD_OK;
    END
  ELSE
    BEGIN
      result:=InitFail(GXhwnd,hRet,'UnLock FAILED');
      exit;
    END;
END;

PROCEDURE DDblankstart;
BEGIN
  IDirectDraw_WaitForVerticalBlank(GXpDD,DDWAITVB_BLOCKBEGIN,0);
END;

PROCEDURE DDblankend;
BEGIN
  IDirectDraw_WaitForVerticalBlank(GXpDD,DDWAITVB_BLOCKEND,0);
END;

PROCEDURE DDHandleMessages;
VAR aMSG:MSG;
BEGIN
  WHILE PeekMessage(@aMSG,0,0,0,PM_NOREMOVE) OR NOT GXbActive OR (GXToRestore AND GraphiXActive) DO
  {  IF GetMessage(@aMSG,0,0,0) THEN }
    BEGIN
      IF GetMessage(@aMSG,0,0,0) THEN
        BEGIN
          TranslateMessage(aMSG);
          DispatchMessage(aMSG);
        END;
    END;
END;

FUNCTION DDGetMouseX:longint;
BEGIN
  DDGetMouseX:=GXmx;
  GXamx:=GXmx;
END;

FUNCTION DDGetMouseY:longint;
BEGIN
  DDGetMouseY:=GXmy;
  GXamy:=GXmy;
END;

FUNCTION DDGetMouseRelX:longint;
BEGIN
  DDGetMouseRelX:=GXmx-GXamx;
  GXamx:=GXmx;
END;

FUNCTION DDGetMouseRelY:longint;
BEGIN
  DDGetMouseRelY:=GXmy-GXamy;
  GXamy:=GXmy;
END;

FUNCTION DDGetMouseButton:byte;
BEGIN
  DDGetMouseButton:=GXmb;
END;

FUNCTION DDSetMouseCallback(cb:pointer);
BEGIN
  IF (cb=nil) THEN GXMouseCallbackUsed:=FALSE;
  GXMouseCallback:=cb;
  IF (cb<>nil) THEN GXMouseCallbackUsed:=TRUE;
END;

FUNCTION ROPsupported(rop:dword):boolean;
VAR i:dword;
BEGIN
  i:=(rop SHR 16) AND $FF;
  ROPsupported:=((DDcaps.dwRops[i SHR 5] SHR (i AND 31)) AND 1=1);
{  PrintString(0,0,hexlong(DDcaps.dwRops[1])); }
{  readkey; }
END;

{----------------------------------------------------------------------------}

PROCEDURE retrace_dd;
BEGIN
  DDblankend;
  DDblankstart;
END;

PROCEDURE retraceend_dd;
BEGIN
  DDblankend;
END;

PROCEDURE retracestart_dd;
BEGIN
  DDblankstart;
END;

PROCEDURE graphwin_dd(x1,y1,x2,y2:longint);
VAR h:longint;
    hret:hresult;
BEGIN
  IF (x1>x2) THEN BEGIN h:=x1;x1:=x2;x2:=h; END;
  IF (y1>y2) THEN BEGIN h:=y1;y1:=y2;y2:=h; END;
  DDcr^.left:=x1;
  DDcr^.top:=y1;
  DDcr^.right:=x2+1;
  DDcr^.bottom:=y2+1;
  IDirectDrawClipper_SetClipList(GXpDDC,DDclip,0);
END;

PROCEDURE lineh_dd(x1,x2,y,f:longint);
VAR dstrect:TRect;
  {  bltfx:TDDBltFX; }
    h:longint;
BEGIN
  IF (x1>x2) THEN BEGIN h:=x1;x1:=x2;x2:=h; END;
  dstrect.left:=x1;
  dstrect.top:=y;
  dstrect.right:=x2+1;
  dstrect.bottom:=y+1;
{  fillchar(bltfx,sizeof(bltfx),0);
  bltfx.dwSize:=sizeof(bltfx); }
  DDbltFX.dwFillColor:=f;
  IDirectDrawSurface_Blt(GXpDDSDraw,@dstrect,nil,nil,DDBLT_COLORFILL{ OR DDBLT_ASYNC},@DDbltFX);
END;

PROCEDURE linev_dd(x,y1,y2,f:longint);
VAR dstrect:TRect;
    h:longint;
BEGIN
  IF (y1>y2) THEN BEGIN h:=y1;y1:=y2;y2:=h; END;
  dstrect.left:=x;
  dstrect.top:=y1;
  dstrect.right:=x+1;
  dstrect.bottom:=y2+1;
  DDbltFX.dwFillColor:=f;
  IDirectDrawSurface_Blt(GXpDDSDraw,@dstrect,nil,nil,DDBLT_COLORFILL,@DDbltFX);
END;

PROCEDURE bar_dd(x1,y1,x2,y2,f:longint);
VAR dstrect:TRect;
    h:longint;
BEGIN
  IF (x1>x2) THEN BEGIN h:=x1;x1:=x2;x2:=h; END;
  IF (y1>y2) THEN BEGIN h:=y1;y1:=y2;y2:=h; END;
  dstrect.left:=x1;
  dstrect.top:=y1;
  dstrect.right:=x2+1;
  dstrect.bottom:=y2+1;
  DDbltFX.dwFillColor:=f;
  IDirectDrawSurface_Blt(GXpDDSDraw,@dstrect,nil,nil,DDBLT_WAIT OR DDBLT_COLORFILL,@DDbltFX);
  REPEAT UNTIL (IDirectDrawSurface_GetBltStatus(GXpDDSDraw,DDGBS_ISBLTDONE)=DD_OK);
END;

PROCEDURE barxor_dd(x1,y1,x2,y2,f:longint);
VAR srcrect,dstrect:TRect;
    h:longint;
BEGIN
{  IF (x1>x2) THEN BEGIN h:=x1;x1:=x2;x2:=h; END;
  IF (y1>y2) THEN BEGIN h:=y1;y1:=y2;y2:=h; END;
  dstrect.left:=x1;
  dstrect.top:=y1;
  dstrect.right:=x2+1;
  dstrect.bottom:=y2+1;
  DDbltFX.dwFillColor:=f;
  IDirectDrawSurface_Blt(GXpDDSDraw,@dstrect,nil,nil,DDBLT_WAIT OR DDBLT_COLORFILL,@DDbltFX);
  REPEAT UNTIL (IDirectDrawSurface_GetBltStatus(GXpDDSPrimary,DDGBS_ISBLTDONE)=DD_OK);
  exit; }

  IF (x1>x2) THEN BEGIN h:=x1;x1:=x2;x2:=h; END;
  IF (y1>y2) THEN BEGIN h:=y1;y1:=y2;y2:=h; END;
  dstrect.left:=x1;
  dstrect.top:=y1;
  dstrect.right:=x2+1;
  dstrect.bottom:=y2+1;
{  srcrect.left:=0;
  srcrect.top:=0;
  srcrect.right:=8;
  srcrect.bottom:=8; }


  DDbltFX.dwFillColor:=f;

{  IDirectDrawSurface_Blt(GXpDDSPrimary,@dstrect,nil,nil,DDBLT_WAIT OR DDBLT_COLORFILL,@DDbltFX);
  REPEAT UNTIL (IDirectDrawSurface_GetBltStatus(GXpDDSPrimary,DDGBS_ISBLTDONE)=DD_OK);
  exit; }


  DDbltFX.dwROP:=SRCINVERT;
{  DDbltFX.lpDDSPattern:=IDirectDrawSurface(GXpDDSPattern); }
{  IDirectDrawSurface_Blt(GXpDDSPrimary,@dstrect,GXpDDSPrimary,@dstrect,DDBLT_WAIT OR DDBLT_ROP,@DDbltFX);
  REPEAT UNTIL (IDirectDrawSurface_GetBltStatus(GXpDDSPrimary,DDGBS_ISBLTDONE)=DD_OK); }

{  IDirectDrawSurface_Blt(GXpDDSPrimary,nil,nil,nil,DDBLT_WAIT OR DDBLT_COLORFILL,@DDbltFX); }
  IDirectDrawSurface_Blt(GXpDDSPattern,nil,nil,nil,DDBLT_WAIT OR DDBLT_COLORFILL{ OR DDBLT_ROP},@DDbltFX);
  REPEAT UNTIL (IDirectDrawSurface_GetBltStatus(GXpDDSPattern,DDGBS_ISBLTDONE)=DD_OK);

  IDirectDrawSurface_Blt(GXpDDSDraw,@dstrect,GXpDDSPattern,@dstrect,DDBLT_WAIT OR DDBLT_ROP,@DDbltFX);
  REPEAT UNTIL (IDirectDrawSurface_GetBltStatus(GXpDDSDraw,DDGBS_ISBLTDONE)=DD_OK);

  exit;
END;

PROCEDURE moverect_dd(x1,y1,x2,y2,x,y:longint);
VAR srcrect,dstrect:TRect;
    h:longint;
BEGIN
  IF (x1>x2) THEN BEGIN h:=x1;x1:=x2;x2:=h; END;
  IF (y1>y2) THEN BEGIN h:=y1;y1:=y2;y2:=h; END;
  srcrect.left:=x1;
  srcrect.top:=y1;
  srcrect.right:=x2+1;
  srcrect.bottom:=y2+1;
  dstrect.left:=x;
  dstrect.top:=y;
  dstrect.right:=x+x2-x1+1;
  dstrect.bottom:=y+y2-y1+1;
  IDirectDrawSurface_Blt(GXpDDSDraw,@dstrect,GXpDDSDraw,@srcrect,DDBLT_WAIT,@DDbltFX);

{  IDirectDrawSurface_SetClipper(GXpDDSPrimary,nil);
  IDirectDrawSurface_BltFast(GXpDDSPrimary,x,y,GXpDDSPrimary,@srcrect,DDBLTFAST_WAIT OR DDBLTFAST_NOCOLORKEY);
  IDirectDrawSurface_SetClipper(GXpDDSPrimary,GXpDDC); }

  REPEAT UNTIL (IDirectDrawSurface_GetBltStatus(GXpDDSDraw,DDGBS_ISBLTDONE)=DD_OK);
END;

{----------------------------------------------------------------------------}

PROCEDURE DDsethwaprocs(col:longint);
BEGIN
  graphwinHW:=@graphwin_dd;
  lineH:=@lineH_dd;
  lineH_solid:=@lineH_dd;
  lineV:=@lineV_dd;
  lineV_solid:=@lineV_dd;
  bar:=@bar_dd;
  bar_solid:=@bar_dd;
{  IF ROPsupported(SRCINVERT) THEN barxor:=@barxor_dd;
  IF ROPsupported(SRCINVERT) THEN barxor_solid:=@barxor_dd; }
  moverect:=@moverect_dd;
END;

{----------------------------------------------------------------------------}

FUNCTION CreateSpecSurface(w,h,bpl:longint;flags:dword;var sp:pointer;var ss:TSpecSurface):boolean;
VAR pDDS:IDirectDrawSurface;
    hret:HRESULT;
    ddsd:TDDSurfaceDesc;
BEGIN
  CreateSpecSurface:=TRUE;
  fillChar(ddsd,sizeof(ddsd),0);
  ddsd.dwSize:=sizeof(ddsd);
  ddsd.dwFlags:=DDSD_CAPS OR DDSD_HEIGHT OR DDSD_WIDTH OR DDSD_PITCH;
  ddsd.dwWidth:=w;
  ddsd.dwHeight:=h;
  ddsd.lPitch:=bpl;
  CASE (flags AND mgxsf_memloction) OF
    gxsf_videomem:ddsd.ddsCaps.dwCaps:=DDSCAPS_BACKBUFFER;
    gxsf_offscreenmem:ddsd.ddsCaps.dwCaps:=DDSCAPS_BACKBUFFER;
    gxsf_sysmem:ddsd.ddsCaps.dwCaps:=DDSCAPS_SYSTEMMEMORY;
  END;
  hRet:=IDirectDraw_CreateSurface(GXpDD,ddsd,pDDS,nil);
  IF (hRet<>DD_OK) THEN
    BEGIN
      CreateSpecSurface:=FALSE;
      exit;
    END;
  ss.DDS:=pDDs;
  sp:=DDGetSurfacePointer(ss);
END;

FUNCTION DestroySpecSurface(var ss:TSpecSurface):boolean;
BEGIN
  IDirectDrawSurface_Release(ss.DDS);
  ss.DDS:=nil;
  DestroySpecSurface:=TRUE;
END;

PROCEDURE InitVideoMem(vmb,vms,omb,oms:dword);
BEGIN
END;

PROCEDURE DDGetPrimarySurface(var DDS:IDirectDrawSurface);
BEGIN
  DDS:=GXpDDSPrimary;
END;

FUNCTION DDEnableSurfaceFlipping(var bs:TSpecSurface):boolean;
BEGIN
  DDEnableSurfaceFlipping:=(IDirectDrawSurface_AddAttachedSurface(GXpDDSPrimary,bs.DDS)=DD_OK);
  GXpDDSDraw:=bs.DDS;
END;

FUNCTION DDFlipSurface(waitforverticalretrace:boolean):boolean;
VAR flags:dword;
BEGIN
  IF waitforverticalretrace THEN flags:=0 ELSE flags:=DDFLIP_NOVSYNC;
  DDFlipSurface:=(IDirectDrawSurface_Flip(GXpDDSPrimary,nil,flags)=DD_OK);
END;

FUNCTION DDDisableSurfaceFlipping(var bs:TSpecSurface):boolean;
BEGIN
  GXpDDSDraw:=GXpDDSPrimary;
  DDDisableSurfaceFlipping:=(IDirectDrawSurface_DeleteAttachedSurface(GXpDDSPrimary,0,bs.DDS)=DD_OK);
  DDLock;
  DDUnLock;
END;

FUNCTION DDGetSurfacePointer(var ss:TSpecSurface):pointer;
VAR hret:HResult;
    ddsd:TDDSurfaceDesc;
BEGIN
  DDGetSurfacePointer:=nil;
  fillchar(ddsd,sizeof(ddsd),0);
  ddsd.dwSize:=sizeof(ddsd);
  hret:=IDirectDrawSurface_Lock(ss.DDS,nil,ddsd,DDLOCK_SURFACEMEMORYPTR OR DDLOCK_WAIT,0);
  IF (hret=DD_OK) THEN
    BEGIN
      DDGetSurfacePointer:=pointer(ddsd.lpSurface);
      hret:=IDirectDrawSurface_UnLock(ss.DDS,nil);
    END;
END;

{----------------------------------------------------------------------------}

PROCEDURE DDPrintString(x,y:longint;txt:string);
VAR h_DC:HDC;
    c:pchar;
BEGIN
  if IDirectDrawSurface_GetDC(GXpDDSPrimary,h_DC)=DD_OK then
    begin
      c:=StrAlloc(length(txt)+1);
      strpcopy(c,txt);
      SetBkColor(h_DC, RGB(0, 0, 255));
      SetTextColor(h_DC, RGB(255, 255, 0));
      TextOut(h_DC,x,y,c,StrLen(c));
      IDirectDrawSurface_ReleaseDC(GXpDDSPrimary,h_DC);
    end;
END;

{PROCEDURE PrintString(x,y:longint;txt:string);
VAR h_DC:HDC;
    c:pchar;
BEGIN
  H_DC:=getDC(gxhwnd);
  c:=StrAlloc(length(txt)+1);
  strpcopy(c,txt);
  SetBkColor(h_DC, RGB(0, 0, 0));
  SetTextColor(h_DC, RGB(255, 255, 255));
  TextOut(h_DC,x,y,c,StrLen(c));
  releaseDC(gxhwnd,h_dc);
END;}

{----------------------------------------------------------------------------}


BEGIN
  DDactive:=FALSE;
  IsInit:=FALSE;
  GXamx:=0;
  GXamy:=0;
END.