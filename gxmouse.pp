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

{
                  ------------------------------------
                               GXMOUSE
                  ------------------------------------
                                v1.10
                  ------------------------------------

VERSION HISTORY

Version 1.10
  + All names in English now
  + 'EnableMouse' - Enables the Mousepointer
  + 'DisableMouse' - Disables the Mousepointer
  + Some minor bugfixes

Version 1.00
  + Support for INT 33h driver
  + Support for colored mouse pointers (size unlimited)

                       --------------------------
}

{$I gxglobal.cfg}
UNIT gxmouse;

INTERFACE

USES gxtype;
{$I gxlocal.cfg}

TYPE PMousePointer=^TMousePointer;
     TMousePointer=RECORD
       x,y:longint;
       mp,hg:pimage;
     END;

     DrawMouseCursorProc=procedure(x,y:longint;fg,bg:pimage);

VAR DefaultMousePointer:PMousePointer;
    MouseVisible:boolean;

PROCEDURE InitMouse;
PROCEDURE ReInitMouse;
PROCEDURE EnableMouse;
PROCEDURE DisableMouse;
PROCEDURE CreateMousePointer(var MousePointer:PMousePointer;img:pimage);
PROCEDURE CreateMousePointer(var MousePointer:PMousePointer;x,y:longint;img:pimage);
PROCEDURE DestroyMousePointer(var MousePointer:PMousePointer);
PROCEDURE InitMousePointer(MousePointer:PMousePointer);
PROCEDURE SetMousePointer(MousePointer:PMousePointer);
PROCEDURE ResetMousePointer;
PROCEDURE SetDrawMouseCursorProc(dmc:DrawMouseCursorProc);
PROCEDURE ResetDrawMouseCursorProc;
PROCEDURE MouseOn;
PROCEDURE MouseOff;
PROCEDURE MouseCoords(var x,y:longint);
FUNCTION MouseMove:boolean;
FUNCTION MouseButton:byte;
PROCEDURE SetMousePosition(x,y:longint);
PROCEDURE SetMouseArea(x1,y1,x2,y2:longint);
FUNCTION IsMouseInArea(x1,y1,x2,y2:longint):byte;
PROCEDURE WaitButtonReleased;
PROCEDURE WaitButtonPressed;

IMPLEMENTATION

USES gxbase,graphix{$IFDEF GO32V2},go32{$ENDIF}
                   {$IFDEF WIN32},gxdd{$ENDIF}
                   {$IFDEF LINUX},gxvgalib{$ENDIF};

VAR aMouseX,aMouseY,MouseX,MouseY:longint;
    aMickeyX,aMickeyY,MickeyX,MickeyY:longint;
    MouseButtonState:word;
    MouseEnabled:boolean;

VAR mx1,my1,mx2,my2,hx,hy:longint;
    CurrentMousePointer:PMousePointer;
    DrawMouseCursor:DrawMouseCursorProc;

PROCEDURE DefaultDrawMouseCursor(x,y:longint;fg,bg:pimage);
BEGIN
  putimageC(x,y,fg);
END;

PROCEDURE SaveBackground;
VAR x1,y1:longint;
BEGIN
  WITH CurrentMousePointer^ DO
    BEGIN
      x1:=Mousex-x;
      y1:=Mousey-y;
      hx:=x1;
      hy:=y1;
      getimage(hx,hy,hg);
   {   putimageC(x1,y1,mp); }
      DrawMouseCursor(x1,y1,mp,hg);
    END;
END;

PROCEDURE MousePointer;
BEGIN
  IF MouseEnabled AND MouseVisible THEN
    BEGIN
      pushgraphwin;
      maxgraphwin;
      putimage(hx,hy,CurrentMousePointer^.hg);
      SaveBackground;
      popgraphwin;
    END;
END;

PROCEDURE MouseOn;
BEGIN
  IF MouseEnabled AND NOT MouseVisible THEN
    BEGIN
      pushgraphwin;
      maxgraphwin;
      SaveBackground;
      MouseVisible:=TRUE;
      popgraphwin;
    END;
END;

PROCEDURE MouseOff;
BEGIN
  IF MouseEnabled AND MouseVisible THEN
    BEGIN
      pushgraphwin;
      maxgraphwin;
      putimage(hx,hy,CurrentMousePointer^.hg);
      MouseVisible:=FALSE;
      popgraphwin;
    END;
END;

PROCEDURE CreateDefaultPointer;
CONST PointerImage1:array[0..19] of word=
        ($8000,$C000,$A000,$9000,$8800,
         $8400,$8200,$8100,$8080,$8040,
         $83E0,$9200,$A900,$C900,$8480,
         $0480,$0240,$0240,$0180,$0000);
      PointerImage2:array[0..19] of word=
        ($8000,$C000,$E000,$F000,$F800,
         $FC00,$FE00,$FF00,$FF80,$FFC0,
         $FFE0,$FE00,$EF00,$CF00,$8780,
         $0780,$03C0,$03C0,$0180,$0000);
VAR x,y,f:longint;
    w1,w2:word;
    offs:pointer;
BEGIN
  new(DefaultMousePointer);
  DefaultMousePointer^.x:=0;
  DefaultMousePointer^.y:=0;
  DefaultMousePointer^.mp:=CreateImageWH(16,20);
  DefaultMousePointer^.hg:=CreateImageWH(16,20);
  setimagetransparencycolor(DefaultMousePointer^.mp,254);
  setimageflags(DefaultMousePointer^.mp,img_transparency);
  offs:=DefaultMousePointer^.mp^.pixeldata;
  FOR y:=0 TO 19 DO
    BEGIN
      w1:=PointerImage1[y];
      w2:=PointerImage2[y];
      FOR x:=0 TO 15 DO
        BEGIN
          IF ((w2 SHL x) AND $8000>0) THEN f:=$00FFFFFF ELSE f:=254;
          IF ((w1 SHL x) AND $8000>0) THEN f:=0;
          CASE gxcurcol OF
          ig_col8:byte(offs^):=byte(f);
          ig_col15,ig_col16:word(offs^):=word(f);
          ig_col24:BEGIN
                  word(offs^):=word(f);
                  byte((offs+2)^):=byte(f SHR 16);
                END;
          ig_col32:longint(offs^):=f;
          END;
          inc(offs,bytperpix);
        END;
    END;
END;

{----- GO32V2 Mouse Handler -------------------------------------------------}

{$IFDEF GO32V2}
VAR Handler_Active:longint;
    user_handler:pointer;
    mouse_regs:trealregs;
    mouse_seginfo:tseginfo;

PROCEDURE MouseHandler;
BEGIN
  IF (handler_active=0) THEN
    BEGIN
      handler_active:=1;
      MouseButtonState:=mouse_regs.bx;
      MickeyX:=smallint(mouse_regs.si);
      MickeyY:=smallint(mouse_regs.di);
      aMouseX:=MouseX;
      aMouseY:=MouseY;
      inc(MouseX,MickeyX-aMickeyX);
      inc(MouseY,MickeyY-aMickeyY);
      aMickeyX:=MickeyX;
      aMickeyY:=MickeyY;
      IF (MouseX<mx1) THEN MouseX:=mx1;
      IF (MouseY<my1) THEN MouseY:=my1;
      IF (MouseX>mx2) THEN MouseX:=mx2;
      IF (MouseY>my2) THEN MouseY:=my2;
      IF (aMouseX<>MouseX) OR (aMouseY<>MouseY) THEN MousePointer;
      handler_active:=0;
    END;
END;

LABEL seg_ds,seg_es,seg_fs;

PROCEDURE callback_handler;assembler;
ASM
  push ds
  push eax
  mov ax,es
  mov ds,ax
  cmp handler_active,1
  je @nocall
  pushad
  mov ax,dosmemselector
  mov fs,ax
  segcs
  mov ax,seg_ds
  mov ds,ax
  segcs
  mov ax,seg_es
  mov es,ax
  call user_handler
  popad
@nocall:
  pop eax
  pop ds
  mov eax,ds:[esi]
  mov es:[edi+42],eax
  add word ptr es:[edi+46],4
  iret
seg_ds:
  DW 1234
seg_es:
  DW 2345
seg_fs:
  DW 3456
END;

PROCEDURE mouse_dummy;
BEGIN
END;

PROCEDURE InitMouseGO32V2;
var r:trealregs;
    w:word;
BEGIN
  Handler_Active:=0;
  user_handler:=@MouseHandler;
  MouseX:=0;
  MouseY:=0;
  MouseButtonState:=0;
  ASM
    mov ax,ds
    mov seg_ds,ax
    mov ax,es
    mov seg_es,ax
    mov ax,fs
    mov seg_fs,ax
  END;
  r.eax:=$0;
  realintr($33,r);
  if (r.eax<>$FFFF) then halt;
  lock_data(handler_active,sizeof(handler_active));
  lock_data(user_handler,sizeof(user_handler));
  lock_data(mouse_regs,sizeof(mouse_regs));
  lock_data(mouse_seginfo,sizeof(mouse_seginfo));
  lock_code(@callback_handler,longint(@mouse_dummy)-longint(@callback_handler));
  get_rm_callback(@Callback_Handler,mouse_regs,mouse_seginfo);
  r.eax:=$0c;
  r.ecx:=$7f;
  r.edx:=longint(mouse_seginfo.offset);
  r.es:=mouse_seginfo.segment;
  realintr($33,r);
END;

PROCEDURE DoneMouseGO32V2;
var r:trealregs;
BEGIN
  r.eax:=$0c;
  r.ecx:=0;
  r.edx:=0;
  r.es:=0;
  realintr($33,r);
  free_rm_callback(mouse_seginfo);
  unlock_data(handler_active,sizeof(handler_active));
  unlock_data(user_handler,sizeof(user_handler));
  unlock_data(mouse_regs,sizeof(mouse_regs));
  unlock_data(mouse_seginfo,sizeof(mouse_seginfo));
  unlock_code(@callback_handler,longint(@mouse_dummy)-longint(@callback_handler));
  fillchar(mouse_seginfo,sizeof(mouse_seginfo),0);
END;
{$ENDIF}

{----- Win32 Mouse Handler --------------------------------------------------}

{$IFDEF WIN32}

PROCEDURE mousecallback;
BEGIN
  MouseButtonState:=DDGetMouseButton;
  aMouseX:=MouseX;
  aMouseY:=MouseY;
  MouseX:=DDGetMouseX;
  MouseY:=DDGetMouseY;
  IF (MouseX<mx1) THEN MouseX:=mx1;
  IF (MouseY<my1) THEN MouseY:=my1;
  IF (MouseX>mx2) THEN MouseX:=mx2;
  IF (MouseY>my2) THEN MouseY:=my2;
  IF (aMouseX<>MouseX) OR (aMouseY<>MouseY) THEN MousePointer;
END;

PROCEDURE InitMouseWIN32;
BEGIN
  DDSetMouseCallback(@mousecallback);
END;

PROCEDURE DoneMouseWIN32;
BEGIN
  DDSetMouseCallback(nil);
END;

{$ENDIF}

{----- Linux SVGAlib Mouse Handler ------------------------------------------}

{$IFDEF LINUX}

PROCEDURE mousecallback;
BEGIN
{  MouseButtonState:=getmousex_vgalib; }
  aMouseX:=MouseX;
  aMouseY:=MouseY;
  MouseX:=getmousex_vgalib;
  MouseY:=getmousey_vgalib;
  IF (MouseX<mx1) THEN MouseX:=mx1;
  IF (MouseY<my1) THEN MouseY:=my1;
  IF (MouseX>mx2) THEN MouseX:=mx2;
  IF (MouseY>my2) THEN MouseY:=my2;
  IF (aMouseX<>MouseX) OR (aMouseY<>MouseY) THEN MousePointer;
END;

PROCEDURE InitMouseVGALIB;
BEGIN
  initmouse_vgalib;
{  setmousehandler_vgalib(@mousecallback); }
END;

PROCEDURE DoneMouseVGALIB;
BEGIN
{  setmousehandler_vgalib(nil); }
END;

{$ENDIF}

{----------------------------------------------------------------------------}

PROCEDURE InitMouse;
BEGIN
  SetMouseArea(0,0,getmaxX,getmaxY);
  SetMousePosition(getmaxX DIV 2,getmaxY DIV 2);
  CreateDefaultPointer;
  MouseVisible:=FALSE;
  MouseEnabled:=TRUE;
  ResetMousePointer;
  MouseCoords(hx,hy);
  MouseOn;
{$IFDEF GO32V2}
  InitMouseGO32V2;
{$ENDIF}
{$IFDEF WIN32}
  InitMouseWIN32;
{$ENDIF}
{$IFDEF LINUX}
  InitMouseVGALIB;
{$ENDIF}
END;

PROCEDURE ReInitMouse;
VAR MouseStat:boolean;
BEGIN
  MouseStat:=MouseVisible;
  MouseVisible:=FALSE;
  DestroyImage(DefaultMousePointer^.mp);
  DestroyMousePointer(DefaultMousePointer);
  SetMouseArea(0,0,getmaxX,getmaxY);
  SetMousePosition(getmaxX DIV 2,getmaxY DIV 2);
  CreateDefaultPointer;
  InitMousePointer(DefaultMousePointer);
  MouseCoords(hx,hy);
  MouseVisible:=FALSE;
  MouseEnabled:=TRUE;
  IF MouseStat THEN MouseOn;
END;

PROCEDURE EnableMouse;
BEGIN
  MouseEnabled:=TRUE;
  MouseOn;
END;

PROCEDURE DisableMouse;
BEGIN
  MouseOff;
  MouseEnabled:=FALSE;
END;

PROCEDURE CreateMousePointer(var MousePointer:PMousePointer;x,y:longint;img:pimage);
BEGIN
  new(MousePointer);
  MousePointer^.x:=x;
  MousePointer^.y:=y;
  MousePointer^.mp:=img;
  MousePointer^.hg:=CloneImage(img);
END;

PROCEDURE CreateMousePointer(var MousePointer:PMousePointer;img:pimage);
BEGIN
  IF (getimageflags(img,img_origincoords)=img_origincoords) THEN
    CreateMousePointer(MousePointer,img^.originX,img^.originY,img) ELSE
    CreateMousePointer(MousePointer,0,0,img);
END;

PROCEDURE DestroyMousePointer(var MousePointer:PMousePointer);
BEGIN
  DestroyImage(MousePointer^.hg);
  dispose(MousePointer);
END;

PROCEDURE InitMousePointer(MousePointer:PMousePointer);
VAR MouseStat:boolean;
BEGIN
  MouseStat:=MouseVisible;
  MouseOff;
  CurrentMousePointer:=MousePointer;
  IF MouseStat THEN MouseOn;
END;

PROCEDURE SetMousePointer(MousePointer:PMousePointer);
BEGIN
  InitMousePointer(MousePointer);
END;

PROCEDURE ResetMousePointer;
BEGIN
  ResetDrawMouseCursorProc;
  InitMousePointer(DefaultMousePointer);
END;

PROCEDURE SetDrawMouseCursorProc(dmc:DrawMouseCursorProc);
BEGIN
  DrawMouseCursor:=dmc;
END;

PROCEDURE ResetDrawMouseCursorProc;
BEGIN
  DrawMouseCursor:=@DefaultDrawMouseCursor;
END;

PROCEDURE MouseCoords(var x,y:longint);
BEGIN
{$IFDEF WIN32}
  DDHandleMessages;
{$ENDIF}
{$IFDEF LINUX}
  mousecallback;
  x:=getmousex_vgalib;
  y:=getmousey_vgalib;
{$ELSE}
  x:=MouseX;
  y:=MouseY;
{$ENDIF}
END;

VAR oldx,oldy:longint;

FUNCTION MouseMove:boolean;
VAR x,y:longint;
BEGIN
  MouseCoords(x,y);
  MouseMove:=(x<>oldx) OR (y<>oldy);
  oldx:=x;
  oldy:=y;
END;

FUNCTION MouseButton:byte;
BEGIN
{$IFDEF WIN32}
  DDHandleMessages;
{$ENDIF}
{$IFDEF LINUX}
  MouseButton:=getmousebutton_vgalib;
{$ELSE}
  MouseButton:=byte(MouseButtonState);
{$ENDIF}
END;

PROCEDURE SetMousePosition(x,y:longint);
BEGIN
  mousex:=x;
  mousey:=y;
END;

PROCEDURE SetMouseArea(x1,y1,x2,y2:longint);
BEGIN
  mx1:=x1;
  my1:=y1;
  mx2:=x2;
  my2:=y2;
END;

FUNCTION IsMouseInArea(x1,y1,x2,y2:longint):byte;
VAR mx,my:longint;
BEGIN
  MouseCoords(mx,my);
  IF (mx>=x1) AND (mx<=x2) AND (my>=y1) AND (my<=y2) THEN
    IsMouseInArea:=MouseButton+128
  ELSE
    IsMouseInArea:=0;
END;

PROCEDURE WaitButtonReleased;
VAR mx,my:longint;
BEGIN
  REPEAT
    MouseCoords(mx,my);
  UNTIL (MouseButton=0);
END;

PROCEDURE WaitButtonPressed;
VAR mx,my:longint;
BEGIN
  REPEAT
    MouseCoords(mx,my);
  UNTIL (MouseButton<>0);
END;

VAR OldExitProc:pointer;

PROCEDURE ExitUnit;
BEGIN
  ExitProc:=OldExitProc;
{$IFDEF GO32V2}
  DoneMouseGO32V2;
{$ENDIF}
{$IFDEF WIN32}
  DoneMouseWIN32;
{$ENDIF}
{$IFDEF LINUX}
  DoneMouseVGALIB;
{$ENDIF}
  IF MouseEnabled THEN
    BEGIN
      DestroyImage(DefaultMousePointer^.mp);
      DestroyMousePointer(DefaultMousePointer);
    END;
  MouseEnabled:=FALSE;
END;

BEGIN
  MouseEnabled:=FALSE;
  OldExitProc:=ExitProc;
  ExitProc:=@ExitUnit;
END.